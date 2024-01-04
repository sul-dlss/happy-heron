# frozen_string_literal: true

module CocinaGenerator
  # This generates a RequestCollection or Collection for a Collection
  class CollectionGenerator
    def self.generate_model(collection_version:)
      new(collection_version:).generate_model
    end

    def initialize(collection_version:)
      @collection_version = collection_version
    end

    def generate_model
      if collection_version.collection.druid
        Cocina::Models::Collection.new(model_attributes.merge(externalIdentifier: collection_version.collection.druid),
                                       false, false)
      else
        Cocina::Models::RequestCollection.new(model_attributes, false, false)
      end
    end

    private

    attr_reader :collection_version

    def model_attributes # rubocop:disable Metrics/AbcSize
      {
        access:,
        administrative: {
          hasAdminPolicy: Settings.h2.hydrus_apo
        },
        identification: {
          sourceId: "hydrus:collection-#{collection_version.collection_id}"
        },
        label: collection_version.name,
        type: Cocina::Models::ObjectType.collection,
        description: Description::CollectionDescriptionGenerator.generate(collection_version:).to_h,
        version: collection_version.version
      }.tap do |h|
        h[:administrative][:partOfProject] = Settings.h2.project_tag unless collection_version.collection.druid
      end
    end

    # TODO: This varies based on what the user selected
    def access
      {
        view: 'world'
      }
    end
  end
end
