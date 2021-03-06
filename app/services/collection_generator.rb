# typed: true
# frozen_string_literal: true

# This generates a RequestCollection or Collection for a Collection
class CollectionGenerator
  extend T::Sig

  sig do
    params(collection_version: CollectionVersion).returns(T.any(Cocina::Models::RequestCollection,
                                                                Cocina::Models::Collection))
  end
  def self.generate_model(collection_version:)
    new(collection_version: collection_version).generate_model
  end

  sig { params(collection_version: CollectionVersion).void }
  def initialize(collection_version:)
    @collection_version = collection_version
  end

  sig { returns(T.any(Cocina::Models::RequestCollection, Cocina::Models::Collection)) }
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

  sig { returns(Hash) }
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
      description: description,
      version: collection_version.version
    }
  end

  sig { returns(Hash) }
  # TODO: This varies based on what the user selected
  def access
    {
      access: 'stanford'
    }
  end

  sig { returns(Hash) }
  def description
    {
      title: [{ value: collection_version.name }],
      relatedResource: RelatedLinksGenerator.generate(object: collection_version)
    }
  end
end
