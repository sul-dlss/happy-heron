# frozen_string_literal: true

module Collections
  # Renders the admin functions for a collection
  class AdminComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    def render?
      helpers.user_with_groups.administrator?
    end

    def options
      opts = [
        ['Select...', 'select']
      ]
      opts << ['Decommission collection', edit_collection_decommission_path(collection)] unless collection.head.decommissioned? # rubocop:disable Layout/LineLength
      options_for_select(opts, 'select')
    end
  end
end
