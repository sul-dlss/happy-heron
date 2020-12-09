# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the history section of the collection (show page)
  class HistoryComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :events, to: :collection
  end
end
