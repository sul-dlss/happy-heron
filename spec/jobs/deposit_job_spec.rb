# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob, type: :job do
  let(:client) do
    instance_double(Dor::Services::Client, objects: objects)
  end
  let(:objects) do
    instance_double(Dor::Services::Client::Objects, register: model)
  end
  let(:model) do
    instance_double(Cocina::Models::DRO, externalIdentifier: druid)
  end
  let(:druid) { 'druid:bc123df4567' }

  before do
    allow(Dor::Services::Client).to receive(:configure).and_return(client)
  end

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

  it 'deposits the stuff' do
    described_class.perform_now(work)
    expect(objects).to have_received(:register)
    expect(work.druid).to eq druid
  end
end
