# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < DraftCollectionForm
  extend T::Sig

  validates :name, :description, :manager_sunets, :access, presence: true
  validates :contact_emails, length: { minimum: 1, message: 'Please add at least contact email.' }
  validates_with CollectionLicenseValidator
end
