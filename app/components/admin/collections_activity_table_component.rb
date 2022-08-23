# frozen_string_literal: true

module Admin
  # Renders a table for collection activity
  class CollectionsActivityTableComponent < ApplicationComponent
    def initialize(events:)
      @events = events
    end
  end
end
