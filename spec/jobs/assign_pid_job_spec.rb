# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignPidJob do
  let(:message) { { model: }.to_json }
  let(:druid) { 'druid:bc123df4567' }

  before do
    allow(Repository).to receive(:valid_version?).and_return(true)
  end

  context "with a work that doesn't have a doi (and hasn't requested one)" do
    let(:model) do
      Cocina::Models::DRO.new(externalIdentifier: druid,
                              type: Cocina::Models::ObjectType.object,
                              label: 'my repository object',
                              version: 1,
                              description: {
                                title: [{ value: 'my repository object' }],
                                purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                              },
                              access: {},
                              administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                              identification: {
                                sourceId: "hydrus:object-#{work.id}"
                              },
                              structural: {
                                contains: []
                              })
    end
    let(:work) { create(:work_version_with_work, :depositing, collection:).work }
    let(:collection) { create(:collection_version_with_collection).collection }

    it 'updates the druid' do
      described_class.new.work(message)
      expect(work.reload.druid).to eq druid
      expect(work.doi).to be_nil
    end
  end

  context "with a registered purl that doesn't have a doi (and has requested one)" do
    let(:model) do
      Cocina::Models::DRO.new(externalIdentifier: druid,
                              type: Cocina::Models::ObjectType.object,
                              label: 'my repository object',
                              version: 1,
                              description: {
                                title: [{ value: 'my repository object' }],
                                purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                              },
                              access: {},
                              administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                              identification: {
                                sourceId: "hydrus:object-#{work.id}"
                              },
                              structural: {
                                contains: []
                              })
    end
    let(:work) { create(:work_version_with_work, :reserving_purl, collection:).work }
    let(:collection) { create(:collection_version_with_collection).collection }

    it 'updates the druid' do
      described_class.new.work(message)
      expect(work.reload.druid).to eq druid
      expect(work.doi).to eq '10.80343/bc123df4567'
    end
  end

  context 'with a work that has a doi' do
    let(:model) do
      Cocina::Models::DRO.new(externalIdentifier: druid,
                              type: Cocina::Models::ObjectType.object,
                              label: 'my repository object',
                              version: 1,
                              description: {
                                title: [{ value: 'my repository object' }],
                                purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                              },
                              access: {},
                              administrative: { hasAdminPolicy: 'druid:xx999xx9999' },
                              identification: {
                                sourceId: "hydrus:object-#{work.id}",
                                doi: '10.25740/bc123df4567'
                              },
                              structural: {
                                contains: []
                              })
    end
    let(:work) { create(:work_version_with_work, collection:, state: 'depositing').work }
    let(:collection) { create(:collection_version_with_collection).collection }

    it 'updates the druid' do
      described_class.new.work(message)
      expect(work.reload.druid).to eq druid
      expect(work.doi).to eq '10.25740/bc123df4567'
    end
  end

  context 'with a collection' do
    let(:model) do
      Cocina::Models::Collection.new(externalIdentifier: druid,
                                     type: Cocina::Models::ObjectType.collection,
                                     label: 'my repository object',
                                     version: 1,
                                     description: {
                                       title: [{ value: 'my repository object' }],
                                       purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
                                     },
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
