# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCompleteJob do
  subject(:run) { instance.work(message) }

  let(:instance) { described_class.new }

  context 'with a not found druid' do
    # An intentionally invalid druid so it does not collide with any test objects
    let(:message) { '{"druid":"druid:aa11ii1111"}' }

    it 'acks the message (and does not raise)' do
      expect(run).to eq(:ack)
    end
  end

  context 'with a work that is depositing' do
    let(:work_version) do
      build(:work_version, :depositing, work:, version_description: 'A new version description')
    end
    let(:work) { create(:work, :with_druid, collection:, depositor: collection.managed_by.first) }
    let(:collection) { build(:collection, :with_managers) }
    let(:collection_version) { create(:collection_version, collection:) }
    let(:message) { "{\"druid\":\"#{work.druid}\"}" }

    before do
      collection.update(head: collection_version)
      work.update(head: work_version)
    end

    it 'updates the work version' do
      expect { run }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
        'CollectionsMailer', 'item_deposited', 'deliver_now',
        { params: {
          user: collection.managed_by.last,
          owner: work.owner,
          collection_version:
        }, args: [] }
      )

      expect(work_version.reload).to be_deposited
      # Event is recorded for SDR, not work creator.
      expect(work_version.work.events.first.user.name).to eq('SDR')
      expect(work_version.work.events.first.description).to eq('What changed: A new version description')
    end
  end

  context 'with a work that is already deposited (embargo was released by DSA)' do
    let(:work_version) do
      build(:work_version, :deposited, work:)
    end
    let(:work) { create(:work, :with_druid) }
    let(:message) { "{\"druid\":\"#{work.druid}\"}" }

    before do
      work.update(head: work_version)
    end

    it "doesn't do a transition" do
      expect { run }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(work_version.reload).to be_deposited
    end
  end

  context 'with a work that is in a version_draft state (embargo was released by DSA)' do
    let(:work_version) do
      build(:work_version, :version_draft, work:)
    end
    let(:work) { create(:work, :with_druid) }
    let(:message) { "{\"druid\":\"#{work.druid}\"}" }

    before do
      work.update(head: work_version)
    end

    it "doesn't do a transition" do
      expect { run }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      expect(work_version.reload).to be_version_draft
    end
  end

  context 'with a collection' do
    let(:collection) { create(:collection, :with_druid) }
    let(:collection_version) { build(:collection_version, :depositing, collection:) }
    let(:message) { "{\"druid\":\"#{collection.druid}\"}" }

    before do
      collection.update(head: collection_version)
    end

    it 'transitions to deposited state' do
      run
      expect(collection_version.reload).to be_deposited
      # Event is recorded for SDR, not collection creator.
      expect(collection_version.collection.events.first.user.name).to eq('SDR')
    end
  end
end
