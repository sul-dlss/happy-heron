# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionGenerator do
  let(:model) { described_class.generate_model(collection: collection) }
  let(:project_tag) { Settings.h2.project_tag }

  context 'without a druid' do
    let(:collection) { build(:collection, name: 'Test title', id: 7) }
    let(:expected_model) do
      {
        type: 'http://cocina.sul.stanford.edu/models/collection.jsonld',
        label: 'Test title',
        version: 0,
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
          ]
        },
        identification: {}
      }
    end

    it 'generates the model' do
      expect(model).to eq Cocina::Models::RequestCollection.new(expected_model)
    end
  end

  context 'with a druid' do
    let(:collection) { build(:collection, id: 7, name: 'Test title', druid: 'druid:bk123gh4567') }
    let(:expected_model) do
      {
        externalIdentifier: 'druid:bk123gh4567',
        type: 'http://cocina.sul.stanford.edu/models/collection.jsonld',
        label: 'Test title',
        version: 0,
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
          ]
        },
        identification: {}
      }
    end

    it 'generates the model' do
      expect(model).to eq Cocina::Models::Collection.new(expected_model)
    end
  end
end
