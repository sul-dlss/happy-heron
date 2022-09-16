# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::WorkCsvGenerator do
  let(:csv) { described_class.generate(relation) }
  let(:relation) { [work] }

  let(:collection) do
    build(:collection, head: build(:collection_version, name: 'Test collection'), id: 2, druid: 'druid:bb000bb0000')
  end

  let(:work) do
    build(:work, id: 1, collection:,
                 druid: 'druid:cn748wq9511',
                 doi: '10.25740/bc123df4567',
                 depositor: user1, owner: user2)
  end

  let(:version) do
    build(:work_version, work:,
                         title: 'Test title 1',
                         state: 'deposited', updated_at: Time.zone.parse('2019-01-01'))
  end

  let(:user1) { build(:user, email: 'user1@stanford.edu') }
  let(:user2) { build(:user, email: 'user2@stanford.edu') }

  before do
    work.head = version
  end

  it 'generates a CSV' do
    expect(csv).to eq <<~CSV
      item title,work id,druid,state,version number,depositor,owner,date created,date last modified,date last deposited,release,visibility,license,DOI,collection title,collection id,collection druid
      Test title 1,1,cn748wq9511,deposited,1,user1,user2,2007-02-10 15:30:45 UTC,2019-01-01 00:00:00 UTC,2019-01-01 00:00:00 UTC,immediate,world,CC0-1.0,10.25740/bc123df4567,Test collection,2,bb000bb0000
    CSV
  end
end
