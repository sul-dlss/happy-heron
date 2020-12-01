# typed: false
# frozen_string_literal: true

module Collections
  # Renders the details about the work (show page)
  class DetailComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :name, :description, :contact_email, to: :collection
  end
end
