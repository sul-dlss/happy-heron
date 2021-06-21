# typed: true
# frozen_string_literal: true

module Collections
  # Renders the information section of the collection (show page)
  class InformationComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion).void }
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    sig { returns(CollectionVersion) }
    attr_reader :collection_version

    delegate :collection, :version_description, to: :collection_version
    delegate :creator, :druid, :purl, to: :collection

    sig { returns(String) }
    def created
      render LocalTimeComponent.new(datetime: collection.created_at)
    end

    sig { returns(String) }
    def last_saved
      render LocalTimeComponent.new(datetime: collection_version.updated_at)
    end

    sig { returns(String) }
    def version
      return '1 - initial version' if collection_version.version == 1

      "#{collection_version.version} - #{version_description}"
    end
  end
end
