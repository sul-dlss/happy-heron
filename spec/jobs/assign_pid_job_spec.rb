# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignPidJob do
  let(:message) { { model: model }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  context 'with a work' do
    let(:model) do
      Cocina::Models::DRO.new(externalIdentifier: druid,
                              type: Cocina::Models::Vocab.object,
                              label: 'my repository object',
                              version: 1,
                              access: {},
                              administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                              identification: {
                                sourceId: "hydrus:object-#{work.id}"
                              },
                              structural: {
                                contains: []
                              })
    end
    let(:work) { create(:work_version_with_work, collection: collection, state: 'depositing').work }
    let(:collection) { create(:collection_version_with_collection).collection }

    it 'updates the druid' do
      described_class.new.work(message)
      expect(work.reload.druid).to eq druid
    end
  end

  context 'with a collection' do
    let(:model) do
      Cocina::Models::Collection.new(externalIdentifier: druid,
                                     type: Cocina::Models::Vocab.collection,
                                     label: 'my repository object',
                                     version: 1,
                                     access: {},
                                     administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                                     identification: {
                                       sourceId: "hydrus:collection-#{collection.id}"
                                     })
    end
    let(:collection) { create(:collection) }

    it 'transitions to deposited state' do
      described_class.new.work(message)
      expect(collection.reload.druid).to eq druid
    end
  end
end
