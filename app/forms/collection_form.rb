# typed: false
# frozen_string_literal: true

# The form for collection creation and editing
class CollectionForm < DraftCollectionForm
  extend T::Sig

  validates :name, :description, :manager_sunets, :access, presence: true
  validates_with CollectionLicenseValidator
end
