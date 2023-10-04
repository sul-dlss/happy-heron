# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepositCompleteAuditor do
  let(:work_still_accessioning) { create(:work_version_with_work_and_collection, state: :depositing, druid: "druid:bc123df4567").work }
  let(:work_done_accessioning) { create(:work_version_with_work_and_collection, state: :depositing, druid: "druid:bc123df4568").work }
  let(:collection_still_accessioning) { create(:collection_version_with_collection, state: :depositing, collection_druid: "druid:bc123df4569").collection }
  let(:collection_done_accessioning) { create(:collection_version_with_collection, state: :depositing, collection_druid: "druid:bc123df4560").collection }

  let(:workflow_client) { instance_double(Dor::Workflow::Client) }

  before do
    allow(Repository).to receive(:valid_version?).and_return(true)
    # These works / collections should be ignored.
    build(:valid_deposited_work_version)
    build(:work_version)
    build(:collection_version_with_collection) # Deposited
    build(:collection_version)
    allow(Dor::Workflow::Client).to receive(:new).and_return(workflow_client)
    allow(workflow_client).to receive(:active_lifecycle).with(druid: work_still_accessioning.druid, milestone_name: "submitted", version: work_still_accessioning.head.version.to_s).and_return(Time.now)
    allow(workflow_client).to receive(:active_lifecycle).with(druid: work_done_accessioning.druid, milestone_name: "submitted", version: work_done_accessioning.head.version.to_s).and_return(nil)
    allow(workflow_client).to receive(:active_lifecycle).with(druid: collection_still_accessioning.druid, milestone_name: "submitted", version: collection_still_accessioning.head.version.to_s).and_return(Time.now)
    allow(workflow_client).to receive(:active_lifecycle).with(druid: collection_done_accessioning.druid, milestone_name: "submitted", version: collection_done_accessioning.head.version.to_s).and_return(nil)
    allow(Honeybadger).to receive(:notify)
    allow(DepositCompleter).to receive(:complete)
  end

  it "calls DepositCompleter and Honeybadger notify" do
    described_class.execute
    expect(DepositCompleter).to have_received(:complete).twice
    expect(DepositCompleter).to have_received(:complete).with(object_version: work_done_accessioning.head)
    expect(DepositCompleter).to have_received(:complete).with(object_version: collection_done_accessioning.head)
    expect(Honeybadger).to have_received(:notify).twice
  end
end
