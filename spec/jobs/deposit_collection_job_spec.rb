# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCollectionJob do
  include Dry::Monads[:result]

  let(:conn) { instance_double(SdrClient::Connection) }
  let(:collection_version) { build_stubbed(:collection_version) }

  before do
    allow(SdrClient::Login).to receive(:run).and_return(Success())
    allow(SdrClient::Connection).to receive(:new).and_return(conn)
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the deposit request is successful' do
    before do
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_return(1234)
    end

    it 'initiates a deposit' do
      described_class.perform_now(collection_version)
      expect(SdrClient::Deposit::CreateResource).to have_received(:run)
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::Deposit::CreateResource).to receive(:run).and_raise('Deposit failed.')
    end

    it 'notifies' do
      described_class.perform_now(collection_version)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
