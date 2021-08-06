# frozen_string_literal: true

# The form for collection settings editing and updating
class CollectionSettingsForm < Reform::Form
  model 'collection'
  feature EmbargoDate

  property :access, default: 'world'
  property :manager_sunets, virtual: true,
                            prepopulator: ->(_options) { self.manager_sunets = manager_sunets_from_model.join(', ') }
  property :email_when_participants_changed
  property :email_depositors_status_changed

  property :release_option, default: 'immediate'
  property :release_duration

  property :license_option
  property :required_license
  property :default_license

  property :depositor_sunets, virtual: true,
                              prepopulator: lambda { |_options|
                                              self.depositor_sunets = depositor_sunets_from_model.join(', ')
                                            }
  property :review_enabled
  property :reviewer_sunets, virtual: true,
                             prepopulator: ->(_options) { self.reviewer_sunets = reviewer_sunets_from_model.join(', ') }

  validates :release_option, presence: true, inclusion: { in: %w[immediate delay depositor-selects] }
  validates :release_duration, inclusion: { in: ::Collection::EMBARGO_RELEASE_DURATION_OPTIONS.values },
                               allow_blank: true
  validates :manager_sunets, :access, presence: true
  validates_with CollectionLicenseValidator

  def deserialize!(params)
    case params['license_option']
    when 'required'
      params['default_license'] = nil
    when 'depositor-selects'
      params['required_license'] = nil
    end
    super(params)
  end

  def sync(*)
    update_depositors
    update_reviewers
    update_managers

    super
  end

  private

  def update_depositors
    model.depositors = field_to_users(depositor_sunets)
  end

  def update_managers
    model.managed_by = field_to_users(manager_sunets)
  end

  def update_reviewers
    return model.reviewed_by = [] unless review_enabled == 'true'

    model.reviewed_by = field_to_users(reviewer_sunets)
  end

  def field_to_users(field)
    sunetids = field.split(/\s*,\s*/).uniq
    emails = sunetids.map { |sunet| "#{sunet}@stanford.edu" }
    emails.map do |email|
      # It's odd that we need to do both, but this is how it's written.
      # See: https://github.com/rails/rails/issues/36027
      User.find_by(email: email) || User.create_or_find_by(email: email)
    end
  end

  def depositor_sunets_from_model
    model.depositors.map(&:sunetid)
  end

  def reviewer_sunets_from_model
    model.reviewed_by.map(&:sunetid)
  end

  def manager_sunets_from_model
    (model.managed_by.presence || [model.creator]).map(&:sunetid)
  end
end
