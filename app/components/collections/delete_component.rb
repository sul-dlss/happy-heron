# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the widget that allows a user to delete a draft collection.
  class DeleteComponent < ApplicationComponent
    sig { params(collection: Collection, style: Symbol).void }
    def initialize(collection:, style: :icon)
      @collection = collection
      @style = style
    end

    sig { returns(Collection) }
    attr_reader :collection

    sig { returns(T::Boolean) }
    def render?
      helpers.allowed_to?(:delete?, collection)
    end
  end
end
