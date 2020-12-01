# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < DraftCollectionForm
  extend T::Sig

  validates :name, :description, :manager_sunets, :access, presence: true
  validates :contact_email, presence: true, format: { with: Devise.email_regexp }
end
