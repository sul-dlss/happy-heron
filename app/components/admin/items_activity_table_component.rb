# frozen_string_literal: true

module Admin
  # Renders a table for item activity
  class ItemsActivityTableComponent < ApplicationComponent
    def initialize(items:)
      @items = items
    end
  end
end
