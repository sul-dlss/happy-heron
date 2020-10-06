# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob, type: :job do
  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:model) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:objects) { instance_double(Dor::Services::Client::Objects, register: model) }
  let(:work) do
    Work.create!(
      title: 'Test title',
      work_type: 'Book',
      subtype: 'Non-fiction',
      contact_email: 'io@io.io',
      created_etdf: '1900',
      abstract: 'test abstract',
      citation: 'test citation',
      access: 'stanford',
      license: 'cc-0'
    )
  end

  before do
    allow(Dor::Services::Client).to receive(:configure).and_return(client)
    described_class.perform_now(work)
  end

  it 'makes a call to dor-services-client to register the work' do
    expect(objects).to have_received(:register)
  end

  it 'assigns the expected identifier to the work' do
    expect(work.druid).to eq druid
  end
end
