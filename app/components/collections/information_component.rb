# frozen_string_literal: true

module Collections
  # Renders the information section of the collection (show page)
  class InformationComponent < ApplicationComponent
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    attr_reader :collection_version

    delegate :collection, :version_description, to: :collection_version
    delegate :creator, :druid, :purl, to: :collection

    def created
      render LocalTimeComponent.new(datetime: collection.created_at)
    end

    def last_saved
      render LocalTimeComponent.new(datetime: collection_version.updated_at)
    end

    def version
      return '1 - initial version' if collection_version.version == 1

      "#{collection_version.version} - #{version_description}"
    end
  end
end
