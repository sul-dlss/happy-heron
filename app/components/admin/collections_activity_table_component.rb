# frozen_string_literal: true

module Admin
  # Renders a table for collection activity
  class CollectionsActivityTableComponent < ApplicationComponent
    def initialize(collections:)
      @collections = collections
    end
  end
end
