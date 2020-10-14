# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:model) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:objects) { instance_double(Dor::Services::Client::Objects, register: model) }
  let(:work) { create(:work) }

  before do
    allow(Dor::Services::Client).to receive(:configure).and_return(client)
    described_class.perform_now(work)
  end

  it 'registers the work' do
    expect(objects).to have_received(:register)
    expect(work.druid).to eq druid
    expect(work.state_name).to eq :deposited
  end
end
