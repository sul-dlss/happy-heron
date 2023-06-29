# frozen_string_literal: true

# The form for collection creation
class DraftCollectionForm < Reform::Form
  feature EmbargoDate
  # This form is a composition of 2 models. See: https://github.com/trailblazer/reform#compositions
  include Composition
  model "collection"

  property :name, on: :collection_version
  property :description, on: :collection_version
  property :version_description, on: :collection_version
  property :access, default: "world", on: :collection

  property :email_when_participants_changed, on: :collection
  property :email_depositors_status_changed, on: :collection

  property :release_option, default: "immediate", on: :collection
  property :release_duration, on: :collection
  property :doi_option, default: "yes", on: :collection

  property :license_option, on: :collection
  property :required_license, on: :collection
  property :default_license, on: :collection
  property :allow_custom_rights_statement, on: :collection
  property :custom_rights_statement_source_option, virtual: true
  property :custom_rights_instructions_source_option, virtual: true
  property :custom_rights_statement_custom_instructions, on: :collection
  property :provided_custom_rights_statement, on: :collection
  property :review_enabled, on: :collection

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
    prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? },
    on: :collection_version do
    property :id
    property :email
    property :_destroy, virtual: true
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
    prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? },
    on: :collection_version do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end

  collection :managed_by, populator: CollectionContributorPopulator.new(:managed_by, User),
    prepopulator: ->(*) { managed_by << collection.creator if managed_by.empty? },
    on: :collection do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :reviewed_by, populator: ReviewersPopulator.new(:reviewed_by, User),
    on: :collection do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :depositors, populator: CollectionContributorPopulator.new(:depositors, User),
    on: :collection do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  validates :release_option, presence: true, inclusion: {in: %w[immediate delay depositor-selects]}
  validates :release_duration, inclusion: {in: ::Collection::EMBARGO_RELEASE_DURATION_OPTIONS.values},
    allow_blank: true

  def deserialize!(params)
    case params["license_option"]
    when "required"
      params["default_license"] = nil
    when "depositor-selects"
      params["required_license"] = nil
    end

    # If the collection doesn't allow custom additional rights statements at
    # all, the source of the custom rights statement and possible collection
    # level rights statement are both necessarily nil
    unless params["allow_custom_rights_statement"] == "true" # form param is still a string at this point
      params["custom_rights_statement_source_option"] = nil
      params["provided_custom_rights_statement"] = nil
    end

    # If the depositor is allowed to enter their own usage rights, provided terms are necessarily nil.
    # If the depositor is provided with specific additional terms of use by the collection, instructions for
    # entering their own terms are necessarily nil.
    if params["custom_rights_statement_source_option"] == "entered_by_depositor"
      params["provided_custom_rights_statement"] = nil
    else
      params["custom_rights_instructions_source_option"] = nil
      params["custom_rights_statement_custom_instructions"] = nil
    end

    # If the collection uses the default instructions for entering custom additional terms of use, custom entered instructions are necessarily nil
    if params["custom_rights_instructions_source_option"] == "default_instructions"
      params["custom_rights_statement_custom_instructions"] = nil
    end

    super(params)
  end

  def collection
    model.fetch(:collection)
  end

  private

  def save_model
    Work.transaction do
      super
      collection.update(head: model.fetch(:collection_version))
    end
  end

  # Let rails routing mechanisms work with this form:
  delegate :persisted?, :to_param, to: :collection
end
