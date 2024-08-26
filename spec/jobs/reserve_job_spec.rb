# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReserveJob do
  include Dry::Monads[:result]

  let(:work) { build(:work, collection:, assign_doi: false) }
  let(:work_version) do
    build(:work_version, :reserving_purl, work:)
  end
  let(:collection) { build(:collection, druid: 'druid:bc123df4567', doi_option: 'depositor-selects') }

  before do
    allow(Honeybadger).to receive(:notify)
  end

  context 'when the reserve request is successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_return(1234)
    end

    it 'reserves the work via sdr-client with the accession param set to false' do
      described_class.perform_now(work_version)
      expect(SdrClient::RedesignedClient).to have_received(:deposit_model)
        .with(a_hash_including(accession: false))
    end
  end

  context 'when the deposit request is not successful' do
    before do
      allow(SdrClient::RedesignedClient).to receive(:deposit_model).and_raise('Deposit failed.')
    end

    it 'notifies' do
      expect { described_class.perform_now(work_version) }.to raise_error(RuntimeError, 'Deposit failed.')
    end
  end
end
