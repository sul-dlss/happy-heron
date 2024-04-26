# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCollectionJob do
  include Dry::Monads[:result]

  let(:collection_version) { build_stubbed(:collection_version) }

  before do
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the deposit request is successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_return(1234)
    end

    it 'initiates a deposit' do
      described_class.perform_now(collection_version)
      expect(SdrClient::RedesignedClient).to have_received(:deposit_model)
    end
  end

  context 'when the deposit update request is successful' do
    let(:collection) { build_stubbed(:collection, :with_collection_druid) }
    let(:collection_version) { build_stubbed(:collection_version, :with_version_description, collection:) }

    before do
      allow(SdrClient::RedesignedClient).to receive(:update_model).and_return(1234)
    end

    it 'initiates an update' do
      described_class.perform_now(collection_version)
      expect(SdrClient::RedesignedClient).to have_received(:update_model)
        .with(model: instance_of(Cocina::Models::Collection),
              version_description: collection_version.version_description)
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_raise('Deposit failed.')
    end

    it 'notifies' do
      described_class.perform_now(collection_version)
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
