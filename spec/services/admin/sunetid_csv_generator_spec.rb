# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SunetidCsvGenerator do
  let(:csv) { described_class.generate(relation) }
  let(:relation) { [] }
  let(:collection) { create(:collection) } # necessary so that we don't have to create one collection per work
  let!(:user) { create(:user, email: 'user1@stanford.edu') }
  let(:druid1) { 'druid:bc123df4567' }
  let(:druid2) { 'druid:bc123df4568' }
  let!(:work1) { create(:work, collection:, druid: druid1, depositor: user, owner: user) }
  let!(:work2) { create(:work, collection:, druid: druid2, depositor: user, owner: user) }

  context 'when the query is empty' do
    it 'generates a CSV' do
      expect(csv).to eq <<~CSV
        druid,depositor sunetid
      CSV
    end
  end

  context 'when the works match the queried druids' do
    let(:relation) { [work1, work2] }

    it 'generates a CSV' do
      expect(csv).to eq <<~CSV
        druid,depositor sunetid
        druid:bc123df4567,user1
        druid:bc123df4568,user1
      CSV
    end
  end

  context 'when the works match the more than one user' do
    let(:relation) { [work1, work3] }
    let!(:user2) { create(:user, email: 'user2@stanford.edu') }
    let(:druid3) { 'druid:bc123df4569' }
    let!(:work3) { create(:work, collection:, druid: druid3, depositor: user2, owner: user2) }

    it 'generates a CSV' do
      expect(csv).to eq <<~CSV
        druid,depositor sunetid
        druid:bc123df4567,user1
        druid:bc123df4569,user2
      CSV
    end
  end
end
