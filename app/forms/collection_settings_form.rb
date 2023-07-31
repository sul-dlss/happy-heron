# frozen_string_literal: true

# The form for collection settings editing and updating
class CollectionSettingsForm < Reform::Form
  model "collection"
  feature EmbargoDate

  property :access, default: "world"

  collection :managed_by, populator: CollectionContributorPopulator.new(:managed_by, User) do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :reviewed_by, populator: ReviewersPopulator.new(:reviewed_by, User) do
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

  property :email_when_participants_changed
  property :email_depositors_status_changed

  property :release_option, default: "immediate"
  property :release_duration
  property :doi_option, default: "yes"

  property :license_option
  property :required_license
  property :default_license
  property :allow_custom_rights_statement, on: :collection
  property :custom_rights_statement_source_option, virtual: true
  property :custom_rights_instructions_source_option, virtual: true
  property :custom_rights_statement_custom_instructions, on: :collection
  property :provided_custom_rights_statement, on: :collection
  property :review_enabled

  validates :release_option, presence: true, inclusion: {in: %w[immediate delay depositor-selects]}
  validate :no_orphaned_embargoes
  validates :release_duration, inclusion: {in: ::Collection::EMBARGO_RELEASE_DURATION_OPTIONS.values}, allow_blank: true
  validates :access, presence: true
  validates :managed_by, length: {minimum: 1, message: "Please add at least one manager."}
  validates_with CollectionLicenseValidator

  def no_orphaned_embargoes
    return unless release_option == "immediate" && @model.release_option != "immediate" && orphaned_embargoes?

    errors.add(:release_option,
      "cannot be set to immediate because some items are embargoed. Please choose another option or contact " \
      "us via the Help link if you have questions.")
  end

  def orphaned_embargoes?
    Work.joins(:head).where(collection: @model).exists?(["work_versions.embargo_date > ?", Time.zone.now])
  end

  # rubocop:disable Rails/SkipsModelValidations
  def save(*)
    model.touch # ensure we set the updated_at column for collection when any participants are changed (e.g. depositor)
    super
  end
  # rubocop:enable Rails/SkipsModelValidations

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
end
