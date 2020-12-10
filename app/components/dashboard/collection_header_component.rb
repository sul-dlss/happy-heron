# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a header for a summary table
  class CollectionHeaderComponent < ApplicationComponent
    MAX_DEPOSITS_TO_SHOW = 4

    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :allowed_to?, to: :helpers

    sig { returns(String) }
    def name
      collection.name.presence || 'No Title'
    end
  end
end
