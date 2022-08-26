# frozen_string_literal: true

module Collections
  # Renders the draft state of a collection version
  class DraftComponent < ApplicationComponent
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    attr_reader :collection_version

    def render?
      collection_version.draft?
    end
  end
end
