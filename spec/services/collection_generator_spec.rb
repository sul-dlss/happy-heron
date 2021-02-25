# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionGenerator do
  let(:model) { described_class.generate_model(collection_version: collection_version) }
  let(:project_tag) { Settings.h2.project_tag }

  context 'without a druid' do
    let(:collection) { build(:collection, id: 7) }
    let(:collection_version) do
      build(:collection_version, :with_related_links, name: 'Test title', collection: collection)
    end
    let(:expected_model) do
      {
        type: 'http://cocina.sul.stanford.edu/models/collection.jsonld',
        label: 'Test title',
        version: 1,
        access: { access: 'stanford' },
        administrative: {
          hasAdminPolicy: 'druid:zx485kb6348',
          partOfProject: project_tag
        },
        description: {
          title: [
            {
              value: 'Test title'
            }
          ],
          relatedResource: [
            {
              type: 'related to',
              title: [{ value: 'My Awesome Research' }],
              access: { url: [{ value: 'http://my.awesome.research.io' }] }
            },
            {
              type: 'related to',
              title: [{ value: 'My Awesome Research' }],
              access: { url: [{ value: 'http://my.awesome.research.io' }] }
            }
          ]
        },
        identification: {
          sourceId: "hydrus:collection-#{collection.id}"
        }
      }
    end

    it 'generates the model' do
      expect(model).to eq Cocina::Models::RequestCollection.new(expected_model)
    end
  end

  context 'with a druid' do
    let(:collection) { build(:collection, id: 7, druid: 'druid:bk123gh4567') }
    let(:collection_version) { build(:collection_version, name: 'Test title', collection: collection) }

    let(:expected_model) do
      {
        externalIdentifier: 'druid:bk123gh4567',
        type: 'http://cocina.sul.stanford.edu/models/collection.jsonld',
        label: 'Test title',
        version: 1,
        access: { access: 'stanford' },
        administrative: {
          hasAdminPolicy: 'druid:zx485kb6348',
          partOfProject: project_tag
        },
        description: {
          title: [
            {
              value: 'Test title'
            }
          ],
          relatedResource: []
        },
        identification: {
          sourceId: "hydrus:collection-#{collection.id}"
        }
      }
    end

    it 'generates the model' do
      expect(model).to eq Cocina::Models::Collection.new(expected_model)
    end
  end
end
