# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SunetidReportQuery do
  let(:request) { described_class.generate(report) }
  let(:collection) { create(:collection) } # necessary so that we don't have to create one collection per work
  let!(:user) { create(:user) }
  let(:druid1) { 'druid:bc123df4567' }
  let(:druid2) { 'druid:bc123df4568' }
  let!(:work1) { create(:work, collection:, druid: druid1, depositor: user, owner: user) }
  let!(:work2) { create(:work, collection:, druid: druid2, depositor: user, owner: user) }

  context 'with two prefixed druids' do
    let(:report) { SunetidReport.new(druids: [work1.druid, work2.druid]) }

    it 'returns all works sorted by email' do
      expect(request.to_a).to eq [work1, work2]
    end
  end

  context 'with two unprefixed druids' do
    let(:report) { SunetidReport.new(druids: [work1.druid_without_namespace, work2.druid_without_namespace]) }

    it 'returns all works sorted by email' do
      expect(request.to_a).to eq [work1, work2]
    end
  end

  context 'with no druids' do
    let(:report) { SunetidReport.new }

    it 'returns all works sorted by email' do
      expect(request.to_a).to eq []
    end
  end
end
