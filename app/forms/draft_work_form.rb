# frozen_string_literal: true

require 'reform/form/coercion'

# The form for draft work creation and editing
class DraftWorkForm < Reform::Form
  feature Edtf
  feature EmbargoDate
  include Composition
  feature Coercion # Casts properties to a specific type

  property :work_type, on: :work_version
  property :description, on: :work_version
  property :subtype, on: :work_version
  property :title, on: :work_version, type: Dry::Types['params.nil'] | Dry::Types['string']
  property :abstract, on: :work_version, type: Dry::Types['params.nil'] | Dry::Types['string']
  property :citation, on: :work_version
  property :default_citation, virtual: true, default: true
  property :citation_auto, virtual: true
  property :collection_id, on: :work
  property :access, on: :work_version
  property :license, on: :work_version
  property :agree_to_terms, on: :work_version
  property :date_last_agreed, on: :work_version
  property :created_type, virtual: true, prepopulator: (proc do |*|
    self.created_type = created_edtf.is_a?(EDTF::Interval) ? 'range' : 'single' unless created_type
  end)
  property :created_edtf, edtf: true, range: true, on: :work_version
  property :published_edtf, edtf: true, on: :work_version
  property :release, virtual: true, prepopulator: (proc do |*|
    self.release = embargo_date.present? ? 'embargo' : 'immediate' if release.blank?
  end)
  property :embargo_date, embargo_date: true, on: :work_version
  property :assign_doi, on: :work, type: Dry::Types['params.nil'] | Dry::Types['params.bool']

  validates_with EmbargoDateParts,
                 if: proc { |form| form.user_can_set_availability? && form.release == 'embargo' }

  validates_with CreatedDateParts,
                 if: proc { |form| form.created_type == 'range' }

  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true

  delegate :user_can_set_availability?, to: :collection

  def deserialize!(params)
    # Choose between using the user provided citation and the auto-generated citation
    params['citation'] = params.delete('citation_auto') if params['default_citation'] == 'true'
    deserialize_embargo(params)
    access_from_collection(params)
    deserialize_license(params)
    super(params)
  end

  # Ensure the collection default overwrites whatever the user supplied
  # rubocop:disable Metrics/AbcSize
  def deserialize_embargo(params)
    case collection.release_option
    when 'delay'
      release_date = collection.release_date
      params['embargo_date(1i)'] = release_date.year.to_s
      params['embargo_date(2i)'] = release_date.month.to_s
      params['embargo_date(3i)'] = release_date.day.to_s
    when 'immediate'
      params['embargo_date(1i)'] = nil
      params['embargo_date(2i)'] = nil
      params['embargo_date(3i)'] = nil
    end
  end
  # rubocop:enable Metrics/AbcSize

  def access_from_collection(params)
    return if collection.access == 'depositor-selects'

    params['access'] = collection.access
  end

  # Ensure the collection's required license overwrites whatever the user supplied
  def deserialize_license(params)
    return unless collection.required_license

    params['license'] = collection.required_license
  end

  contributor = lambda { |*|
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :first_name
    property :last_name
    property :full_name
    property :orcid
    property :role_term
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
    property :weight, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
  }

  collection :contributors,
             populator: ContributorPopulator.new(:contributors, Contributor),
             prepopulator: ->(*) { contributors << Contributor.new if contributors.blank? },
             on: :work_version,
             &contributor

  collection :authors,
             populator: ContributorPopulator.new(:authors, Author),
             prepopulator: ->(*) { authors << Author.new if authors.blank? },
             on: :work_version,
             &contributor

  collection :attached_files,
             populator: AttachedFilesPopulator.new(:attached_files, AttachedFile),
             on: :work_version do
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :label
    property :hide, type: Dry::Types['params.bool']
    # The file property is only necessary if there is a server side validation error and we need to re-render the form.
    property :file, virtual: true
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
                              prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? },
                              on: :work_version do
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :email
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :keywords,
             populator: KeywordsPopulator.new(:keywords, Keyword),
             prepopulator: ->(*) { keywords << Keyword.new if keywords.blank? },
             on: :work_version do
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :label
    property :uri
    property :cocina_type
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :related_works,
             populator: RelatedWorksPopulator.new(:related_works, RelatedWork),
             prepopulator: ->(*) { related_works << RelatedWork.new if related_works.blank? },
             on: :work_version do
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :citation
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
                             prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? },
                             on: :work_version do
    property :id, type: Dry::Types['params.nil'] | Dry::Types['params.integer']
    property :link_title
    property :url
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  delegate :collection, :persisted?, :to_param, to: :work

  def work
    model[:work]
  end

  def description
    return if model.fetch(:work_version).deposited?

    super
  end

  # Wrap the entire operation (root model and nested model save) in a transaction.
  # See https://github.com/apotonick/disposable/blob/v0.5.0/lib/disposable/twin/save.rb#L11
  def save!(*)
    Work.transaction do
      super
    end
  end

  # Ensure that this work version is now the head of the work versions for this work
  def save_model
    super
    work.update(head: model.fetch(:work_version))
  end

  # Override reform so that this looks just like a Work
  def model_name
    Work.model_name
  end
end
