# frozen_string_literal: true

module CocinaGenerator
  # This generates a RequestCollection or Collection for a Collection
  class CollectionGenerator
    def self.generate_model(collection_version:)
      new(collection_version: collection_version).generate_model
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

    def model_attributes
      {
        access: access,
        administrative: {
          hasAdminPolicy: Settings.h2.hydrus_apo,
          partOfProject: Settings.h2.project_tag
        },
        identification: {
          sourceId: "hydrus:collection-#{collection_version.collection_id}"
        },
        label: collection_version.name,
        type: Cocina::Models::Vocab.collection,
        description: Description::CollectionDescriptionGenerator.generate(collection_version: collection_version),
        version: collection_version.version
      }
    end

    # TODO: This varies based on what the user selected
    def access
      {
        access: 'world'
      }
    end
  end
end
