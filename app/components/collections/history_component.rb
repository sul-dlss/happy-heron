# frozen_string_literal: true

module Collections
  # Renders the history section of the collection (show page)
  class HistoryComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :events, to: :collection
  end
end
