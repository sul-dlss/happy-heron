# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < CollectionFormDraft
  extend T::Sig

  validates :name, :description, :managers, :access, presence: true
  validates :contact_email, presence: true, format: { with: Devise.email_regexp }
end
