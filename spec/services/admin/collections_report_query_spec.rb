# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CollectionsReportQuery do
  let(:request) { described_class.generate(report) }

  let!(:collection1) { create(:collection_version_with_collection, state: 'deposited', name: 'bCollection').collection }
  let!(:collection2) do
    create(:collection_version_with_collection, state: 'first_draft', name: 'cCollection').collection
  end
  let!(:collection3) do
    collection_version = create(:collection_version_with_collection, state: 'version_draft',
                                                                     updated_at: Time.zone.parse('2018-06-01'),
                                                                     name: 'aCollection')
    collection = collection_version.collection
    collection.created_at = Time.zone.parse('2018-01-01')
    collection.save!
    collection
  end

  context 'without filters' do
    let(:report) { Admin::CollectionsReport.new }

    it 'returns all collections sorted by name' do
      expect(request).to eq [collection3, collection1, collection2]
    end
  end

  context 'with deposited status' do
    let(:report) { Admin::CollectionsReport.new(status_deposited: true) }

    it 'returns deposited collections' do
      expect(request).to eq [collection1]
    end
  end

  context 'with first draft status' do
    let(:report) { Admin::CollectionsReport.new(status_first_draft: true) }

    it 'returns first draft collections' do
      expect(request).to eq [collection2]
    end
  end

  context 'with version draft status' do
    let(:report) { Admin::CollectionsReport.new(status_version_draft: true) }

    it 'returns version draft collections' do
      expect(request).to eq [collection3]
    end
  end

  context 'with date created start' do
    let(:report) { Admin::CollectionsReport.new(date_created_start: '2019-01-01') }

    it 'returns collections created after the date' do
      expect(request).to eq [collection1, collection2]
    end
  end

  context 'with date created end' do
    let(:report) { Admin::CollectionsReport.new(date_created_end: '2019-01-01') }

    it 'returns collections created after the date' do
      expect(request).to eq [collection3]
    end
  end

  context 'with date modified start' do
    let(:report) { Admin::CollectionsReport.new(date_modified_start: '2019-06-01') }

    it 'returns collections modified after the date' do
      expect(request).to eq [collection1, collection2]
    end
  end

  context 'with date modified end' do
    let(:report) { Admin::CollectionsReport.new(date_modified_end: '2019-06-01') }

    it 'returns collections modified after the date' do
      expect(request).to eq [collection3]
    end
  end
end
