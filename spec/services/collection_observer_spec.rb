# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionObserver do
  let(:collection) { build(:collection) }

  describe '.after_update_published' do
    subject(:action) { described_class.after_update_published(collection_version, nil) }

    let(:change_set) { CollectionChangeSet::PointInTime.new(collection).diff(collection_after) }

    before do
      collection.event_context = { user: collection.creator, change_set: change_set }
    end

    context 'when depositors are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.depositors = [collection.depositors.first] } }

      context 'when the collection is configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :with_depositors, :email_depositors_status_changed, depositor_count: 2)
        end

        let(:collection_version) do
          create(:collection_version_with_collection, collection: collection)
        end

        it 'sends emails to those removed' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'deposit_access_removed_email', 'deliver_now',
            { params: { user: collection.depositors.last, collection: collection }, args: [] }
          )
        end
      end

      context 'when the collection is configured to send participant change notifications' do
        let(:reviewer) { create(:user) }
        let(:reviewer2) { create(:user) }
        let(:manager) { create(:user) }
        let(:collection) do
          create(:collection, :with_depositors, :email_when_participants_changed,
                 managed_by: [manager], reviewed_by: [reviewer, reviewer2], depositor_count: 2)
        end

        let(:collection_version) do
          create(:collection_version_with_collection, collection: collection)
        end

        it 'sends emails to the managers about the participants change' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: manager, collection: collection }, args: [] }
          )
        end

        it 'sends emails to the reviewers about the participants change' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: reviewer, collection: collection }, args: [] }
          ).and have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: reviewer2, collection: collection }, args: [] }
          )
        end
      end

      context 'when the collection is not configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :email_when_participants_changed, :with_depositors, depositor_count: 2)
        end

        let(:collection_version) do
          create(:collection_version_with_collection, collection: collection)
        end

        it 'sends no emails' do
          expect { action }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'deposit_access_removed_email', anything, anything
          )
        end
      end

      context 'when the collection is not configured to send participant change notifications' do
        let(:collection) do
          create(:collection, :email_depositors_status_changed, :with_depositors, depositor_count: 2)
        end

        let(:collection_version) do
          create(:collection_version_with_collection, collection: collection)
        end

        it 'does not send notification about the participant change' do
          expect { action }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', anything, anything
          )
        end
      end
    end

    context 'when managers are added to a collection' do
      let(:collection) { collection_version.collection }
      let(:manager) { create(:user) }
      let(:collection_after) { collection.dup.tap { |col| col.managed_by = [manager] } }

      let(:collection_version) do
        create(:collection_version_with_collection)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'manage_access_granted_email', 'deliver_now',
          { params: { user: manager, collection: collection }, args: [] }
        )
      end
    end

    context 'when managers are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.managed_by = [collection.managed_by.first] } }
      let(:collection) do
        create(:collection, :with_managers, manager_count: 2)
      end

      let(:collection_version) do
        create(:collection_version_with_collection, collection: collection)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'manage_access_removed_email', 'deliver_now',
          { params: { user: collection.managed_by.last, collection: collection }, args: [] }
        )
      end
    end

    context 'when reviewers are added to a collection' do
      let(:collection) { collection_version.collection }
      let(:reviewer) { create(:user) }
      let(:collection_after) { collection.dup.tap { |col| col.reviewed_by = [reviewer] } }
      let(:collection_version) do
        create(:collection_version_with_collection)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_granted_email', 'deliver_now',
          { params: { user: reviewer, collection: collection }, args: [] }
        )
      end
    end

    context 'when reviewers are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.reviewed_by = [collection.reviewed_by.first] } }
      let(:collection) do
        create(:collection, :with_reviewers)
      end
      let(:collection_version) do
        create(:collection_version_with_collection, collection: collection)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_removed_email', 'deliver_now',
          { params: { user: collection.reviewed_by.last, collection: collection }, args: [] }
        )
      end
    end
  end
end
