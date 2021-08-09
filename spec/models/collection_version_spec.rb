# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionVersion do
  subject(:collection_version) { build(:collection_version) }

  describe '#updatable?' do
    subject { collection_version.updatable? }

    context 'when depositing' do
      let(:collection_version) { build(:collection_version, :depositing) }

      it { is_expected.to be false }
    end

    context 'when deposited and is the head version' do
      let(:collection_version) { create(:collection_version_with_collection, :deposited) }

      it { is_expected.to be true }
    end

    context 'when deposited and is not the head version' do
      let(:collection_version) { build(:collection_version, :deposited) }

      it { is_expected.to be false }
    end

    context 'when a draft' do
      let(:collection_version) { build(:collection_version, :version_draft) }

      it { is_expected.to be true }
    end
  end

  describe 'state machine flow' do
    let(:collection) { collection_version.collection }
    let(:manager1) { create(:user) }
    let(:manager2) { create(:user) }

    before do
      collection.update(head: collection_version)
      collection.managed_by = [manager1, manager2]
    end

    describe 'a begin_deposit event' do
      let(:collection_version) { create(:collection_version, :first_draft) }

      before do
        allow(DepositCollectionJob).to receive(:perform_later)
      end

      it 'transitions from first_draft to depositing' do
        expect { collection_version.begin_deposit! }
          .to change(collection_version, :state)
          .to('depositing')
          .and change(Event, :count).by(1)
                                    .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                                           'CollectionsMailer', 'manage_access_granted_email', 'deliver_now',
                                           { params: {
                                             user: manager1,
                                             collection_version: collection_version
                                           }, args: [] }
                                         ))
                                    .and(have_enqueued_job(ActionMailer::MailDeliveryJob).with(
                                           'CollectionsMailer', 'manage_access_granted_email', 'deliver_now',
                                           { params: {
                                             user: manager2,
                                             collection_version: collection_version
                                           }, args: [] }
                                         ))
        expect(DepositCollectionJob).to have_received(:perform_later).with(collection_version)
      end
    end

    describe 'an update_metadata event' do
      let(:collection_version) { create(:collection_version, :new) }

      before do
        collection.event_context = { user: collection.creator }
      end

      it 'transitions to version draft' do
        expect { collection_version.update_metadata! }
          .to change(collection_version, :state)
          .from('new').to('first_draft')
          .and change(Event, :count).by(1)
      end
    end

    describe 'a deposit_complete event' do
      let(:collection_version) { create(:collection_version, :depositing) }

      it 'transitions to deposited' do
        expect { collection_version.deposit_complete! }
          .to change(collection_version, :state)
          .to('deposited')
          .and change(Event, :count).by(1)
      end
    end
  end
end
