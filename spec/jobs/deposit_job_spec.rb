# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include Dry::Monads[:result]

  let(:client) { instance_double(Dor::Services::Client, objects: objects) }
  let(:druid) { 'druid:bc123df4567' }
  let(:model) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }
  let(:work) { build(:work, id: 8) }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(Success())
    allow(DepositStatusJob).to receive(:perform_later)
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the deposit request is successful' do
    before do
      allow(SdrClient::Deposit).to receive(:model_run).and_return(1234)
    end

    it 'initiates a DepositStatusJob' do
      described_class.perform_now(work)
      expect(SdrClient::Deposit).to have_received(:model_run)
      expect(DepositStatusJob).to have_received(:perform_later).with(work: work, job_id: 1234)
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::Deposit).to receive(:model_run).and_raise('Deposit failed.')
    end

    it 'notifies' do
      described_class.perform_now(work)
      expect(SdrClient::Deposit).to have_received(:model_run)
      expect(DepositStatusJob).not_to have_received(:perform_later)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
