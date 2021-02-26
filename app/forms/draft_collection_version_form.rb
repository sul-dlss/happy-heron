# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class DraftCollectionVersionForm < Reform::Form
  extend T::Sig
  model 'collection_version' # Required so that rails knows where to route this form to.

  property :name, on: :collection_version
  property :description, on: :collection_version
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

  # Ensure that this collection is now the head of the collection versions for this collection
  def save_model
    Work.transaction do
      super
      model.collection.update(head: model)
    end
  end

  # Required so that rails knows this is an update and uses the PATCH method for the form.
  delegate :persisted?, to: :model
end
