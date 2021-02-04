# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the details section of the collection (show page)
  class DetailComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :name, :description, :contact_emails, to: :collection
  end
end
