# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WorkReportQuery do
  let(:request) { described_class.generate(report) }
  let(:collection) { create(:collection) } # necessary so that we don't have to create one collection per work
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  let(:user3) { create(:user, email: 'aaaa@stanford.edu') }
  let!(:work1) { create(:work_version_with_work, state: 'deposited', collection: collection, owner: user1).work }
  let!(:work2) { create(:work_version_with_work, state: 'first_draft', collection: collection, owner: user2).work }
  let!(:work3) do
    work = create(:work_version_with_work, state: 'version_draft',
                                           collection: collection,
                                           owner: user3,
                                           updated_at: Time.zone.parse('2018-06-01')).work
    work.created_at = Time.zone.parse('2005-01-01')
    work.save!
    work
  end

  context 'without filters' do
    let(:report) { WorkReport.new(state: ['']) }

    it 'returns all works sorted by email' do
      expect(request.to_a).to eq [work3, work1, work2]
    end
  end

  context 'with collection' do
    let(:collection2) { create(:collection) } # necessary so that we don't have to create one collection per work
    let!(:work1) { create(:work_version_with_work, collection: collection2, owner: user1).work }
    let(:report) { WorkReport.new(state: [''], collection_id: collection2.id) }

    it 'returns the works in the collection' do
      expect(request.to_a).to eq [work1]
    end
  end

  context 'with deposited status' do
    let(:report) { WorkReport.new(state: ['deposited']) }

    it 'returns deposited works' do
      expect(request).to eq [work1]
    end
  end

  context 'with first draft status' do
    let(:report) { WorkReport.new(state: ['first_draft']) }

    it 'returns first draft works' do
      expect(request).to eq [work2]
    end
  end

  context 'with version draft status' do
    let(:report) { WorkReport.new(state: ['version_draft']) }

    it 'returns version draft works' do
      expect(request).to eq [work3]
    end
  end

  context 'with date created start' do
    # Note the works factory has a created_at of 2007-02-10
    let(:report) { WorkReport.new(date_created_start: '2006-01-01', state: []) }

    it 'returns works created after the date' do
      expect(request).to eq [work1, work2]
    end
  end

  context 'with date created end' do
    # Note the works factory has a created_at of 2007-02-10
    let(:report) { WorkReport.new(date_created_end: '2006-01-01', state: []) }

    it 'returns works created before the date' do
      expect(request).to eq [work3]
    end
  end

  context 'with date modified start' do
    let(:report) { WorkReport.new(date_modified_start: '2019-06-01', state: []) }

    it 'returns works modified after the date' do
      expect(request).to eq [work1, work2]
    end
  end

  context 'with date modified end' do
    let(:report) { WorkReport.new(date_modified_end: '2019-06-01', state: []) }

    it 'returns works modified after the date' do
      expect(request).to eq [work3]
    end
  end
end
