# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionObserver do
  let(:collection) { build(:collection) }

  describe '.after_update_published' do
    subject(:action) { described_class.after_update_published(collection, nil) }

    let(:change_set) { CollectionChangeSet.from(collection).to(collection_after) }

    before do
      collection.event_context = { user: collection.creator, change_set: change_set }
    end

    context 'when depositors are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.depositors = [collection.depositors.first] } }

      context 'when the collection is configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :deposited, :with_depositors, :email_depositors_status_changed, depositor_count: 2)
        end

        it 'sends emails to those removed' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'deposit_access_removed_email', 'deliver_now',
            { params: { user: collection.depositors.last, collection: collection }, args: [] }
          )
        end
      end

      context 'when the collection is not configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :deposited, :with_depositors, depositor_count: 2)
        end

        it 'sends no emails' do
          expect { action }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
        end
      end
    end

    context 'when reviewers are added to a collection' do
      let(:collection) { create(:collection, :deposited) }
      let(:reviewer) { create(:user) }
      let(:collection_after) { collection.dup.tap { |col| col.reviewers = [reviewer] } }

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_granted_email', 'deliver_now',
          { params: { user: reviewer, collection: collection }, args: [] }
        )
      end
    end
  end
end
