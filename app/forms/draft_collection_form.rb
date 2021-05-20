# typed: false
# frozen_string_literal: true

# The form for collection creation
class DraftCollectionForm < Reform::Form
  extend T::Sig
  feature EmbargoDate
  # This form is a composition of 2 models. See: https://github.com/trailblazer/reform#compositions
  include Composition
  model 'collection'

  property :name, on: :collection_version
  property :description, on: :collection_version
  property :version_description, on: :collection_version
  property :access, default: 'world', on: :collection
  property :manager_sunets, virtual: true, on: :collection,
                            prepopulator: ->(_options) { self.manager_sunets = manager_sunets_from_model.join(', ') }
  property :email_when_participants_changed, on: :collection
  property :email_depositors_status_changed, on: :collection

  property :release_option, default: 'immediate', on: :collection
  property :release_duration, on: :collection

  property :license_option, on: :collection
  property :required_license, on: :collection
  property :default_license, on: :collection

  property :depositor_sunets, virtual: true, on: :collection,
                              prepopulator: lambda { |_options|
                                              self.depositor_sunets = depositor_sunets_from_model.join(', ')
                                            }
  property :review_enabled, on: :collection
  property :reviewer_sunets, virtual: true, on: :collection,
                             prepopulator: ->(_options) { self.reviewer_sunets = reviewer_sunets_from_model.join(', ') }

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

  validates :release_option, presence: true, inclusion: { in: %w[immediate delay depositor-selects] }
  validates :release_duration, inclusion: { in: ::Collection::EMBARGO_RELEASE_DURATION_OPTIONS.values },
                               allow_blank: true

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

  def collection
    model.fetch(:collection)
  end

  private

  sig { void }
  def update_depositors
    collection.depositors = field_to_users(depositor_sunets)
  end

  sig { void }
  def update_managers
    collection.managed_by = field_to_users(manager_sunets)
  end

  sig { void }
  def update_reviewers
    return collection.reviewed_by = [] unless review_enabled == 'true'

    collection.reviewed_by = field_to_users(reviewer_sunets)
  end

  sig { params(field: String).returns(T::Array[User]) }
  def field_to_users(field)
    sunetids = field.split(/\s*,\s*/).uniq
    emails = sunetids.map { |sunet| "#{sunet}@stanford.edu" }
    emails.map do |email|
      # It's odd that we need to do both, but this is how it's written.
      # See: https://github.com/rails/rails/issues/36027
      User.find_by(email: email) || User.create_or_find_by(email: email)
    end
  end

  sig { returns(T::Array[String]) }
  def depositor_sunets_from_model
    collection.depositors.map(&:sunetid)
  end

  sig { returns(T::Array[String]) }
  def reviewer_sunets_from_model
    collection.reviewed_by.map(&:sunetid)
  end

  sig { returns(T::Array[String]) }
  def manager_sunets_from_model
    (collection.managed_by.presence || [collection.creator]).map(&:sunetid)
  end

  def save_model
    Work.transaction do
      super
      collection.update(head: model.fetch(:collection_version))
    end
  end

  # Let rails routing mechanisms work with this form:
  delegate :persisted?, :to_param, to: :collection
end
