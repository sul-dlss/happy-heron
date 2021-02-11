# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < DraftCollectionForm
  extend T::Sig

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
                              prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? } do
    property :id
    property :email
    property :_destroy, virtual: true
    validates :email, format: { with: Devise.email_regexp }
  end

  validates :name, :description, :manager_sunets, :access, presence: true
  validates :contact_emails, length: { minimum: 1, message: 'Please add at least contact email.' }
  validates_with CollectionLicenseValidator
end
