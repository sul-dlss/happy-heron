# typed: true
# frozen_string_literal: true

# This generates a RequestCollection or Collection for a Collection
class CollectionGenerator
  extend T::Sig

  sig { params(collection: Collection).returns(T.any(Cocina::Models::RequestCollection, Cocina::Models::Collection)) }
  def self.generate_model(collection:)
    new(collection: collection).generate_model
  end

  sig { params(collection: Collection).void }
  def initialize(collection:)
    @collection = collection
  end

  sig { returns(T.any(Cocina::Models::RequestCollection, Cocina::Models::Collection)) }
  def generate_model
    if collection.druid
      Cocina::Models::Collection.new(model_attributes.merge(externalIdentifier: collection.druid), false, false)
    else
      Cocina::Models::RequestCollection.new(model_attributes, false, false)
    end
  end

  private

  attr_reader :collection

  sig { returns(Hash) }
  def model_attributes
    {
      access: access,
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo,
        partOfProject: Settings.h2.project_tag
      },
      identification: {
        # It would be great if we could send a sourceId with a collection, because then we
        # could receive a message knowing when it was deposited. Currently cocina-models doesn't
        # support sourceIds on collections
        # sourceId: "hydrus:collection-#{collection.id}"
      },
      label: collection.name,
      type: Cocina::Models::Vocab.collection,
      description: { title: [{ value: collection.name }] },
      version: collection.version
    }
  end

  sig { returns(Hash) }
  # TODO: This varies based on what the user selected
  def access
    {
      access: 'stanford'
    }
  end
end
