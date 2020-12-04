# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the widget that allows a user to delete a draft collection.
  class DeleteComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    sig { returns(T::Boolean) }
    def render?
      helpers.allowed_to?(:delete?, collection)
    end
  end
end
