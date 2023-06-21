# frozen_string_literal: true

# The form for collection version editing
class CollectionVersionForm < DraftCollectionVersionForm
  # A copy of what is in DraftCollectionForm, but with validation on email
  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
    prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? } do
    property :id
    property :email
    property :_destroy, virtual: true
    validates :email, format: {with: Devise.email_regexp}
  end

  validates :name, :description, presence: true
  validates :contact_emails, length: {minimum: 1, message: "Please add at least contact email."}
end
