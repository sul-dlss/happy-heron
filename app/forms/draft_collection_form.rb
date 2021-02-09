# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class DraftCollectionForm < Reform::Form
  extend T::Sig
  feature EmbargoDate

  EMBARGO_RELEASE_DURATION_OPTIONS = { '6 months from date of deposit': '6 months',
                                       '1 year from date of deposit': '1 year',
                                       '2 years from date of deposit': '2 years',
                                       '3 years from date of deposit': '3 years' }.freeze

  property :name
  property :description
  property :access, default: 'world'
  property :manager_sunets, virtual: true, prepopulator: lambda { |_options|
    self.manager_sunets = manager_sunets_from_model.join(', ')
  }
  property :email_when_participants_changed
  property :email_depositors_status_changed

  property :release_option, default: 'immediate'
  property :release_duration
  property :release_date, embargo_date: true, assign_if: ->(params) { params['release_option'] == 'delay' }

  property :license_option
  property :required_license
  property :default_license

  property :depositor_sunets, virtual: true, prepopulator: lambda { |_options|
    self.depositor_sunets = depositor_sunets_from_model.join(', ')
  }
  property :review_enabled
  property :reviewer_sunets, virtual: true, prepopulator: lambda { |_options|
    self.reviewer_sunets = reviewer_sunets_from_model.join(', ')
  }

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
                              prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? } do
    property :id
    property :email
    property :_destroy, virtual: true
    validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
                             prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? } do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end

  validates :release_date, embargo_date: true
  validates :release_option, presence: true, inclusion: { in: %w[immediate delay depositor-selects] }
  validates :release_duration, inclusion: { in: EMBARGO_RELEASE_DURATION_OPTIONS.values }, allow_blank: true

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

  sig { void }
  def update_depositors
    model.depositors = field_to_users(depositor_sunets)
  end

  sig { void }
  def update_managers
    model.managers = field_to_users(manager_sunets)
  end

  sig { void }
  def update_reviewers
    return model.reviewed_by = [] unless review_enabled == 'true'

    model.reviewed_by = field_to_users(reviewer_sunets)
  end

  sig { params(field: String).returns(T::Array[User]) }
  def field_to_users(field)
    sunetids = field.split(/\s*,\s*/)
    emails = sunetids.map { |sunet| "#{sunet}@stanford.edu" }
    emails.map do |email|
      # It's odd that we need to do both, but this is how it's written.
      # See: https://github.com/rails/rails/issues/36027
      User.find_by(email: email) || User.create_or_find_by(email: email)
    end
  end

  sig { returns(T::Array[String]) }
  def depositor_sunets_from_model
    model.depositors.map(&:sunetid)
  end

  sig { returns(T::Array[String]) }
  def reviewer_sunets_from_model
    model.reviewed_by.map(&:sunetid)
  end

  sig { returns(T::Array[String]) }
  def manager_sunets_from_model
    (model.managers.presence || [model.creator]).map(&:sunetid)
  end
end
