# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the header for the collection show page (title and create new link)
  class LinksComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion).void }
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    sig { returns(CollectionVersion) }
    attr_reader :collection_version

    delegate :related_links, to: :collection_version
  end
end
