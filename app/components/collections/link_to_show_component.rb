# frozen_string_literal: true

module Collections
  # Draws the link to the collection show page
  class LinkToShowComponent < ApplicationComponent
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    def link
      link_to name, collection, name:
    end

    def name
      @name ||= Collections::DetailComponent.new(collection_version:).name
    end

    attr_reader :collection_version

    delegate :collection, to: :collection_version
  end
end
