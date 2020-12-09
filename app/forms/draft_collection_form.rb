# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class DraftCollectionForm < Reform::Form
  extend T::Sig
  feature EmbargoDate

  property :name
  property :description
  property :contact_email
  property :access, default: 'world'
  property :creator, writable: false
  property :manager_sunets, virtual: true, prepopulator: lambda { |_options|
    self.manager_sunets = manager_sunets_from_model.join(', ')
  }
  property :email_when_participants_changed
  property :email_depositors_status_changed

  property :release_option, default: 'immediate'
  property :release_duration
  property :release_date, embargo_date: true, assign_if: ->(params) { params['release_option'] == 'delay' }

  property :depositor_sunets, virtual: true, prepopulator: lambda { |_options|
    self.depositor_sunets = depositor_sunets_from_model.join(', ')
  }
  property :review_enabled, virtual: true, default: -> { model.review_enabled? ? 'true' : 'false' }
  property :reviewer_sunets, virtual: true, prepopulator: lambda { |_options|
    self.reviewer_sunets = reviewer_sunets_from_model.join(', ')
  }

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
                             prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? } do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end

  validate :reviewable_form
  validates :release_date, embargo_date: true
  validates :release_option, presence: true, inclusion: { in: %w[immediate delay depositor-selects] }
  validates :release_duration, inclusion: {
    in: ['1 month', '2 months', '6 months', '1 year', '2 years', '3 years']
  }, allow_blank: true

  def sync(*)
    update_depositors
    update_reviewers
    update_managers

    super
  end

  private

  sig { void }
  def reviewable_form
    return if review_enabled != 'true' || reviewer_sunets.present?

    errors.add(:reviewer_sunets, 'must be provided when review is enabled')
  end

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
    return model.reviewers = [] unless review_enabled == 'true'

    model.reviewers = field_to_users(reviewer_sunets)
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
    model.reviewers.map(&:sunetid)
  end

  sig { returns(T::Array[String]) }
  def manager_sunets_from_model
    (model.managers.presence || [model.creator]).map(&:sunetid)
  end
end
