# frozen_string_literal: true

require 'reform/form/coercion'

# The form for deposit work creation and editing (which includes validation)
class WorkForm < BaseWorkForm
  validates :abstract, :access, :title, presence: true, allow_nil: false
  validates :keywords, length: { minimum: 1, message: 'Please add at least one keyword.' }
  validates :attached_files, length: { minimum: 1, message: 'Please add at least one file.' },
                             if: lambda {
                                   if work.head
                                     %w[browser zip].include?(upload_type) && work.head.attached_files.none?
                                   else
                                     %w[browser zip].include?(upload_type)
                                   end
                                 }
  validates :contact_emails, length: { minimum: 1, message: 'Please add at least one contact email.' }
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :authors, length: { minimum: 1, message: 'Please add at least one author.' }
  validates :created_edtf, created_in_past: true
  validates :published_edtf, created_in_past: true
  validates :release, presence: true,
                      inclusion: { in: %w[immediate embargo] },
                      if: :availability_component_present?
  validates :embargo_date, embargo_date: true, if: :availability_component_present?
  validates :agree_to_terms, presence: true
  validates :upload_type, presence: true
  validates :new_user_version, presence: true, if: :not_first_version?
  validates :user_version, presence: true

  has_contributors(validate: true)

  # Copies form properties to the model. Called internally by reform prior to save.
  def sync(*)
    maybe_assign_doi
    super
  end

  def deserialize!(params)
    deserialize_doi(params)
    super
  end

  # Force assign_doi to match what the collection enforces
  def deserialize_doi(params)
    case collection.doi_option
    when 'no'
      params['assign_doi'] = 'false'
    when 'yes'
      params['assign_doi'] = 'true'
    end
  end

  private

  delegate :already_immediately_released?, :already_embargo_released?, to: :work

  # This is responsible for setting the DOI if the user requests one on a new version.
  def maybe_assign_doi
    work.doi = Doi.for(work.druid) if assign_doi?
  end

  def assign_doi?
    return false unless work.druid

    will_assign_doi?
  end

  def availability_component_present?
    return false if already_immediately_released?
    return false if already_embargo_released?

    collection.user_can_set_availability?
  end

  def not_first_version?
    work_version.version != 1
  end
end
