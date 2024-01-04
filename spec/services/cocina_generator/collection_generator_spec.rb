# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::CollectionGenerator do
  let(:model) { described_class.generate_model(collection_version:) }
  let(:project_tag) { Settings.h2.project_tag }
  let(:description) do
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, ' \
      'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
  end

  context 'without a druid' do
    let(:collection) { build(:collection, id: 7) }
    let(:collection_version) do
      build(:collection_version, :with_related_links, :with_contact_emails,
            name: 'Test title',
            description:,
            collection:)
    end
    let(:expected_model) do
      Cocina::Models::RequestCollection.new(
        {
          type: Cocina::Models::ObjectType.collection,
          label: 'Test title',
          version: 1,
          access: { view: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348',
            partOfProject: project_tag
          },
          description: {
            access: {
              accessContact: [
                {
                  value: 'io@io.io',
                  type: 'email',
                  displayLabel: 'Contact'
                }
              ]
            },
            title: [
              {
                value: 'Test title'
              }
            ],
            note: [
              {
                value: description,
                type: 'abstract'
              }
            ],
            relatedResource: [
              {
                title: [{ value: 'My Awesome Research' }],
                access: { url: [{ value: 'http://my.awesome.research.io' }] }
              },
              {
                title: [{ value: 'My Awesome Research' }],
                access: { url: [{ value: 'http://my.awesome.research.io' }] }
              }
            ]
          },
          identification: {
            sourceId: "hydrus:collection-#{collection.id}"
          }
        }
      )
    end

    it 'generates the model' do
      expect(model.to_h).to eq expected_model.to_h
    end
  end

  context 'with a druid' do
    let(:collection) { build(:collection, id: 7, druid: 'druid:bk123gh4567') }
    let(:collection_version) do
      build(:collection_version, :with_contact_emails,
            name: 'Test title',
            description:,
            collection:)
    end

    let(:expected_model) do
      Cocina::Models::Collection.new(
        {
          externalIdentifier: 'druid:bk123gh4567',
          type: Cocina::Models::ObjectType.collection,
          label: 'Test title',
          version: 1,
          access: { view: 'world' },
          administrative: {
            hasAdminPolicy: 'druid:zx485kb6348'
          },
          description: {
            title: [
              {
                value: 'Test title'
              }
            ],
            note: [
              {
                value: description,
                type: 'abstract'
              }
            ],
            purl: 'https://purl.stanford.edu/bk123gh4567',
            access: {
              accessContact: [
                {
                  value: 'io@io.io',
                  type: 'email',
                  displayLabel: 'Contact'
                }
              ]
            }
          },
          identification: {
            sourceId: "hydrus:collection-#{collection.id}"
          }
        }
      )
    end

    it 'generates the model' do
      expect(model.to_h).to eq expected_model.to_h
    end
  end
end
