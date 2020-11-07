# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < Reform::Form
  property :name
  property :description
  property :contact_email
  property :managers, default: -> { model.creator.sunetid }
  property :access, default: 'world'
  property :creator, writable: false
  property :depositor_sunets, virtual: true, prepopulator: lambda { |_options|
    self.depositor_sunets = depositor_sunets_from_model.join(', ')
  }
  property :review_enabled, virtual: true, default: -> { model.reviewers.present? ? 'true' : 'false' }
  property :reviewer_sunets, virtual: true, default: -> { model.reviewers }

  def sync(*)
    update_depositors
    update_reviewers

    super
  end

  validates :name, :description, :managers, :access, presence: true
  validates :contact_email, presence: true, format: { with: Devise.email_regexp }

  private

  def update_depositors
    sunetids = depositor_sunets.split(/\s*,\s*/)
    emails = sunetids.map { |sunet| "#{sunet}@stanford.edu" }
    model.depositors = emails.map do |email|
      # It's odd that we need to do both, but this is how it's written.
      # See: https://github.com/rails/rails/issues/36027
      User.find_by(email: email) || User.create_or_find_by(email: email)
    end
  end

  def update_reviewers
    model.reviewers = (review_enabled == 'true' ? reviewer_sunets : nil)
  end

  def depositor_sunets_from_model
    model.depositors.map(&:sunetid)
  end
end
