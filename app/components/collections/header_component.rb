# typed: false
# frozen_string_literal: true

module Collections
  # Renders the header for the collection show page (title and create new link)
  class HeaderComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion).void }
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    sig { returns(CollectionVersion) }
    attr_reader :collection_version

    delegate :depositing?, :collection, to: :collection_version

    sig { returns(String) }
    def name
      collection_version.name.presence || 'No Title'
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end

    def can_create_work?
      collection_version.accessioned?
    end
  end
end
