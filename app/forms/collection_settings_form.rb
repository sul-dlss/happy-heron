# frozen_string_literal: true

# The form for collection settings editing and updating
class CollectionSettingsForm < Reform::Form
  model 'collection'
  feature EmbargoDate

  property :access, default: 'world'

  collection :managed_by, populator: CollectionContributorPopulator.new(:managed_by, User) do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :reviewed_by, populator: ReviewersPopulator.new(:reviewed_by, User) do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  collection :depositors, populator: CollectionContributorPopulator.new(:depositors, User),
                          on: :collection do
    property :id, writeable: false
    property :sunetid, writeable: false
    property :name
    property :_destroy, virtual: true, type: Dry::Types['params.nil'] | Dry::Types['params.bool']
  end

  property :email_when_participants_changed
  property :email_depositors_status_changed

  property :release_option, default: 'immediate'
  property :release_duration
  property :doi_option, default: 'yes'

  property :license_option
  property :required_license
  property :default_license
  # rubocop:disable Layout/LineLength
  property :custom_rights_statement_option,
           virtual: true,
           prepopulator: lambda { |*|
                           self.custom_rights_statement_option = if allow_custom_rights_statement && provided_custom_rights_statement.blank?
                                                                   'entered_by_depositor'
                                                                 elsif allow_custom_rights_statement && provided_custom_rights_statement.present?
                                                                   'custom'
                                                                 else
                                                                   'none'
                                                                 end
                         }
  # rubocop:enable Layout/LineLength
  property :allow_custom_rights_statement, on: :collection
  property :custom_rights_statement_custom_instructions, on: :collection
  property :provided_custom_rights_statement, on: :collection
  property :review_enabled

  validates :release_option, presence: true, inclusion: { in: %w[immediate delay depositor-selects] }
  validate :no_orphaned_embargoes
  validates :release_duration, inclusion: { in: ::Collection::EMBARGO_RELEASE_DURATION_OPTIONS.values },
                               allow_blank: true
  validates :access, presence: true
  validates :managed_by, length: { minimum: 1, message: 'Please add at least one manager.' }
  validates_with CollectionLicenseValidator

  def no_orphaned_embargoes
    return unless release_option == 'immediate' && @model.release_option != 'immediate' && orphaned_embargoes?

    errors.add(:release_option,
               'cannot be set to immediate because some items are embargoed. Please choose another option or contact ' \
               'us via the Help link if you have questions.')
  end

  def orphaned_embargoes?
    Work.joins(:head).where(collection: @model).exists?(['work_versions.embargo_date > ?', Time.zone.now])
  end

  # rubocop:disable Rails/SkipsModelValidations
  def save(*)
    model.touch # ensure we set the updated_at column for collection when any participants are changed (e.g. depositor)
    super
  end
  # rubocop:enable Rails/SkipsModelValidations

  # rubocop:disable Metrics/MethodLength
  def deserialize!(params)
    case params['license_option']
    when 'required'
      params['default_license'] = nil
    when 'depositor-selects'
      params['required_license'] = nil
    end

    case params['custom_rights_statement_option']
    when 'entered_by_depositor'
      params['allow_custom_rights_statement'] = 'true'
      params['provided_custom_rights_statement'] = nil
    when 'custom'
      params['allow_custom_rights_statement'] = 'true'
      params['custom_rights_statement_custom_instructions'] = nil
    when 'none'
      params['allow_custom_rights_statement'] = 'false'
      params['provided_custom_rights_statement'] = nil
      params['custom_rights_statement_custom_instructions'] = nil
    end

    super(params)
  end
  # rubocop:enable Metrics/MethodLength
end
