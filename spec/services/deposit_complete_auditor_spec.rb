# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCompleteAuditor do
  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(Repository).to receive(:valid_version?).and_return(true)
    allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
    allow(Honeybadger).to receive(:notify)
    allow(DepositCompleter).to receive(:complete)
    allow(workflow_client).to receive(:status)
      .with(druid: object.druid, version: object.head.version.to_s)
      .and_return(instance_double(Dor::Workflow::Client::Status, display_simplified: status))
  end

  context 'with a work still going through accessioning' do
    let(:status) { 'In accessioning (described)' }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: 'druid:bc123df4567').work }

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a collection still going through accessioning' do
    let(:status) { 'In accessioning (described, published, deposited)' }
    let(:object) do
      create(:collection_version_with_collection, state: :depositing, collection_druid: 'druid:bc123df4569').collection
    end

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a work not yet going through accessioning' do
    let(:status) { 'Registered' }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: 'druid:bc123df4567').work }

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a collection not yet going through accessioning' do
    let(:status) { 'Registered' }
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
    let(:status) { 'Accessioned' }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: 'druid:bc123df4568').work }

    it 'calls DepositCompleter and notifies Honeybadger' do
      described_class.execute
      expect(DepositCompleter).to have_received(:complete).with(object_version: object.head)
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'with an accessioned collection' do
    let(:status) { 'Accessioned' }
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
    let(:status) { 'Unknown Status' }
    let(:object) { create(:work_version_with_work_and_collection, state: :depositing, druid: nil).work }

    before do
      allow(workflow_client).to receive(:active_lifecycle)
        .and_raise(Dor::MissingWorkflowException,
                   'Failed to retrieve resource: get https://workflow-service-prod.stanford.edu/' \
                   '/objects//lifecycle?version=1&active-only=true (HTTP status 404)')
    end

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end

  context 'with a collection not yet assigned a druid' do
    # The code doesn't check the status if the druid is blank, so the value here shouldn't really matter
    let(:status) { 'Unknown Status' }
    let(:object) { create(:collection_version_with_collection, state: :depositing, collection_druid: nil).collection }

    before do
      allow(workflow_client).to receive(:active_lifecycle)
        .and_raise(Dor::MissingWorkflowException,
                   'Failed to retrieve resource: get https://workflow-service-prod.stanford.edu/' \
                   '/objects//lifecycle?version=1&active-only=true (HTTP status 404)')
    end

    it 'skips calling DepositCompleter and notifying Honeybadger' do
      described_class.execute
      expect(DepositCompleter).not_to have_received(:complete)
      expect(Honeybadger).not_to have_received(:notify)
    end
  end
end
