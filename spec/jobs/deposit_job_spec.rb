# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include Dry::Monads[:result]

  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:model) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:work) { create(:work) }
  let(:result) { Success() }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(result)
    allow(SdrClient::Deposit).to receive(:model_run).and_return(1234)
    allow(SdrClient::BackgroundJobResults).to receive(:show).and_return(background_result)
  end

  context 'when the job is successful' do
    let(:background_result) { { status: 'complete', output: { druid: druid } } }

    it 'registers the work' do
      described_class.perform_now(work)
      expect(SdrClient::Deposit).to have_received(:model_run)
      expect(work.druid).to eq druid
      expect(work.state_name).to eq :deposited
    end
  end

  context 'when the job is not successful' do
    let(:background_result) { { status: 'complete', output: { errors: [{ title: 'something went wrong' }] } } }

    it 'registers the work' do
      expect { described_class.perform_now(work) }.to raise_error('something went wrong')
      expect(SdrClient::Deposit).to have_received(:model_run)
    end
  end
end
