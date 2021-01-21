# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the details section of the collection (show page)
  class DetailComponent < Collections::ShowComponent
    delegate :name, :description, :contact_email, to: :collection
  end
end
