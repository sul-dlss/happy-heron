# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCompleteAuditor do
  let(:object_client) { instance_double(Dor::Services::Client::Object, version: object_version) }
  let(:object_version) { instance_double(Dor::Services::Client::ObjectVersion, status: version_status) }
  let(:version_status) { instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, accessioning?: accessioning) }
  let(:druid) { object.druid }

  before do
    allow(Repository).to receive(:valid_version?).and_return(true)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(Honeybadger).to receive(:notify)
    allow(DepositCompleter).to receive(:complete)
  end

  context 'with a work still going through accessioning' do
    let(:accessioning) { true }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: 'druid:bc123df4567').work }

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a collection still going through accessioning' do
    let(:accessioning) { true }
    let(:object) do
      create(:collection_version_with_collection, state: :depositing, collection_druid: 'druid:bc123df4569').collection
    end

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with an accessioned work' do
    let(:accessioning) { false }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: 'druid:bc123df4568').work }

    it 'calls DepositCompleter and notifies Honeybadger' do
      described_class.execute
      expect(DepositCompleter).to have_received(:complete).with(object_version: object.head)
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'with an accessioned collection' do
    let(:accessioning) { false }
    let(:object) do
      create(:collection_version_with_collection, state: :depositing, collection_druid: 'druid:bc123df4560').collection
    end

    it 'calls DepositCompleter and notifies Honeybadger' do
      described_class.execute
      expect(DepositCompleter).to have_received(:complete).with(object_version: object.head)
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'with a work not yet assigned a druid' do
    # The code doesn't check the status if the druid is blank, so the value here shouldn't really matter
    let(:accessioning) { true }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: nil).work }

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a collection not yet assigned a druid' do
    # The code doesn't check the status if the druid is blank, so the value here shouldn't really matter
    let(:accessioning) { true }
    let(:object) { create(:collection_version_with_collection, state: :depositing, collection_druid: nil).collection }

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end
end
