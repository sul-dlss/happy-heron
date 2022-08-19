# frozen_string_literal: true

module Admin
  # Renders a table for item activity
  class ItemsActivityTableComponent < ApplicationComponent
    def initialize(events:)
      @events = events
    end
  end
end
