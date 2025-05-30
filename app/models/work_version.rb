# frozen_string_literal: true

# Models the deposit of an single version of a digital repository object
# rubocop:disable Metrics/ClassLength
class WorkVersion < ApplicationRecord
  include AggregateAssociations

  # Format with hash, e.g., { user_id: 'mjgiarlo', work_id: 123, work_version: 9 }
  GLOBUS_ENDPOINT_TEMPLATE = '%<user_id>s/work%<work_id>d/version%<work_version>d'

  belongs_to :work
  has_many :contributors, dependent: :destroy, class_name: 'Contributor'
  has_many :authors, -> { order(weight: :asc) }, inverse_of: :work_version, dependent: :destroy, class_name: 'Author'
  before_destroy do
    # Unfortunately the STI relationships above, don't delete everything.
    # I first tried this approach, but it didn't work either
    #   has_many :abstract_contributors, dependent: :destroy
    # So this seems to take care of it.
    AbstractContributor.where(work_version_id: id).destroy_all
  end
  before_save :clean_abstract

  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many :attached_files, dependent: :destroy
  has_many :keywords, dependent: :destroy

  validates :state, presence: true
  validates :license, inclusion: { in: License.license_list(include_displayable: true) }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  strip_attributes allow_empty: true, only: %i[title abstract citation]

  scope :awaiting_review_by, lambda { |user|
    with_state(:pending_approval)
      .joins(:work)
      .left_outer_joins(work: { collection: :reviewed_by })
      .left_outer_joins(work: { collection: :managed_by })
      .where('reviewers.user_id = %s OR managers.user_id = %s', user.id, user.id)
      .distinct
  }

  enum :access, {
    stanford: 'stanford',
    world: 'world'
  }

  # provides helper method to infer upload type... e.g. work_version.globus?
  enum :upload_type, {
    browser: 'browser',
    globus: 'globus',
    zipfile: 'zipfile'
  }

  enum :globus_origin, {
    stanford_gdrive: 'stanford_gdrive',
    oak: 'oak',
    sherlock: 'sherlock'
  }

  LINK_TEXT = ':link will be inserted here automatically when available:'
  DOI_TEXT = ':DOI will be inserted here automatically when available:'

  after_update_commit -> { work.broadcast_update }

  include WorkVersionStateMachine

  # 6/3/2022 : Added to prevent https://app.honeybadger.io/projects/77112/faults/85827019
  # Postgres does not like this particular unicode character and will reject the query if it is present.
  # This likely occurs when a user copy and pastes text into the abstract text box from PDF/Word/etc.
  # see for example https://stackoverflow.com/questions/29320369/coping-with-string-contains-null-byte-sent-from-users
  # and https://stackoverflow.com/questions/31671634/handling-unicode-sequences-in-postgresql
  def clean_abstract
    return unless abstract&.include?("\u0000")

    abstract.delete!("\u0000")
    Rails.logger.info { "Null character stripped from abstract for work_version id #{id}." }
  end

  def updatable?
    can_update_metadata? || deposited?
  end

  def draft?
    version_draft? || first_draft?
  end

  def deleteable?
    first_draft? || purl_reservation? || (version == 1 && (pending_approval? || rejected?))
  end

  def add_purl_to_citation
    return unless citation

    update!(citation: citation.gsub(LINK_TEXT, work.purl))
  end

  def add_doi_to_citation
    return unless citation

    update!(citation: citation.gsub(DOI_TEXT, "https://doi.org/#{work.doi}."))
  end

  # Points the blob records to the preservation store and removes the locally cached copies of the files
  def switch_to_preserved_items!
    staged_files.each do |af|
      blob = af.file.blob
      locally_cached_file = locally_cached_file_for(blob)
      blob.key = af.create_preservation_active_storage_key
      blob.service_name = ActiveStorage::Service::SdrService::SERVICE_NAME
      blob.save!
      File.unlink(locally_cached_file) if locally_cached_file
    end
  end

  # the terms agreement checkbox value is not persisted in the database with the work and the value is instead:
  #  false if (a) never previously accepted or (b) not accepted in the last year; it is true otherwise
  def agree_to_terms
    work.owner.agreed_to_terms_recently?
  end

  # the terms agreement checkbox value is not persisted in the database with the work but instead at the user level
  def agree_to_terms=(value)
    return if value == false || value == '0' || work.owner.agreed_to_terms_recently?

    # update the last time the terms of agreement was accepted for this depositor
    #  if it has not been accepted within the defined timeframe and the checkbox was checked
    work.owner.update(last_work_terms_agreement: Time.zone.now)
  end

  # Ensure that EDTF dates get an EDTF serialization
  def published_edtf=(edtf)
    case edtf
    when nil, EDTF::Interval
      super
    when Date
      super(edtf.to_edtf)
    end
  end

  # Ensure that EDTF dates get an EDTF serialization
  def created_edtf=(edtf)
    case edtf
    when nil, EDTF::Interval
      super
    when Date
      super(edtf.to_edtf)
    else
      raise TypeError, 'Expected a Date or EDTF::Interval'
    end
  end

  # see https://github.com/inukshuk/edtf-ruby for details on the parsing gem used
  def published_edtf
    EDTF.parse(super)
  end

  def created_edtf
    EDTF.parse(super)
  end

  def purl_reservation?
    work_type == WorkType.purl_reservation_type.id
  end

  def previous_version
    return nil if version == 1 # shortcut any query checks if we are on the first version

    work.work_versions.find { |check_work_version| check_work_version.version == version - 1 }
  end

  # @return [Array<AttachedFile>] a list of files not in preservation
  def staged_files
    @staged_files ||= attached_files.reject { |af| ActiveStorage::Service::SdrService.accessible?(af.file.blob) }
  end

  # @return [Array<AttachedFile>] a list of files not in preservation or globus
  def staged_local_files
    @staged_local_files ||= attached_files.reject do |af|
      ActiveStorage::Service::SdrService.accessible?(af.file.blob) \
      || ActiveStorage::Service::GlobusService.accessible?(af.file.blob)
    end
  end

  # @return [Array<AttachedFile>] a list of files in preservation
  def preserved_files
    @preserved_files ||= attached_files.select { |af| ActiveStorage::Service::SdrService.accessible?(af.file.blob) }
  end

  # current state might take some time, so may want to display a spinner
  def wait_state?
    depositing? || reserving_purl? || unzipping_state? || fetching_globus_state?
  end

  # in one of the unzipping states
  def unzipping_state?
    unzip_first_draft? || unzip_version_draft? || unzip_pending_approval? || unzip_depositing?
  end

  # in one of the fetching globus states
  def fetching_globus_state?
    fetch_globus_first_draft? || fetch_globus_version_draft? \
    || fetch_globus_pending_approval? || fetch_globus_depositing?
  end

  def globus_endpoint_fullpath
    File.join(
      Settings.globus.uploads_directory,
      globus_endpoint,
      '/'
    )
  end

  # @return [Boolean] true if the user_version is different from the previous version's user_version
  # or this is the first version
  def new_user_version?
    user_version != previous_version&.user_version
  end

  def embargoed?
    embargo_date.present? && embargo_date > Time.zone.today
  end

  private

  def locally_cached_file_for(blob)
    return unless blob.service.instance_of?(ActiveStorage::Service::DiskService)

    blob.service.path_for(blob.key)
  end
end
# rubocop:enable Metrics/ClassLength
