# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionObserver do
  let(:collection) { create(:collection) }
  let!(:collection_version) { create(:collection_version_with_collection, collection: collection) }

  describe '.settings_updated' do
    subject(:action) do
      described_class.settings_updated(collection, user: collection.creator, change_set: change_set)
    end

    let(:change_set) { CollectionChangeSet::PointInTime.new(collection).diff(collection_after) }

    context 'when depositors are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.depositors = [collection.depositors.first] } }

      context 'when the collection is configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :with_depositors, :email_depositors_status_changed, depositor_count: 2)
        end

        it 'sends emails to those removed' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'deposit_access_removed_email', 'deliver_now',
            { params: { user: collection.depositors.last, collection_version: collection_version }, args: [] }
          )
        end
      end

      context 'when the collection is configured to send participant change notifications' do
        let(:reviewer) { create(:user) }
        let(:reviewer2) { create(:user) }
        let(:manager) { create(:user) }
        let(:collection) do
          # Notice that manager is also a reviewer.
          create(:collection, :with_depositors, :email_when_participants_changed,
                 managed_by: [manager], reviewed_by: [reviewer, reviewer2, manager], depositor_count: 2)
        end

        it 'sends emails to the managers about the participants change' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: manager, collection_version: collection_version }, args: [] }
          )
        end

        it 'sends emails to the reviewers about the participants change' do
          expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: reviewer, collection_version: collection_version }, args: [] }
          ).and have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', 'deliver_now',
            { params: { user: reviewer2, collection_version: collection_version }, args: [] }
          )
        end
      end

      context 'when the collection is not configured to send notifications to depositors' do
        let(:collection) do
          create(:collection, :email_when_participants_changed, :with_depositors, depositor_count: 2)
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

        it 'does not send notification about the participant change' do
          expect { action }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            'CollectionsMailer', 'participants_changed_email', anything, anything
          )
        end
      end
    end

    context 'when managers are added to a collection' do
      let(:collection) { create(:collection) }
      let(:manager) { create(:user) }
      let(:collection_after) { collection.dup.tap { |col| col.managed_by = [manager] } }

      it 'sends emails to those added' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'manage_access_granted_email', 'deliver_now',
          { params: { user: manager, collection_version: collection_version }, args: [] }
        )
      end
    end

    context 'when managers are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.managed_by = [collection.managed_by.first] } }
      let(:collection) do
        create(:collection, :with_managers, manager_count: 2)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'manage_access_removed_email', 'deliver_now',
          { params: { user: collection.managed_by.last, collection_version: collection_version }, args: [] }
        )
      end
    end

    context 'when reviewers are added to a collection' do
      let(:collection) { create(:collection) }
      let(:reviewer) { create(:user) }
      let(:collection_after) { collection.dup.tap { |col| col.reviewed_by = [reviewer] } }

      it 'sends emails to those added' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_granted_email', 'deliver_now',
          { params: { user: reviewer, collection_version: collection_version }, args: [] }
        )
      end
    end

    context 'when manager added as reviewer to a collection' do
      let(:collection) { create(:collection, :email_when_participants_changed, managed_by: [manager]) }
      let(:manager) { create(:user) }
      let(:collection_after) do
        collection.dup.tap do |col|
          col.reviewed_by << manager
          col.managed_by = [manager] # Already set on collection. Duping here.
        end
      end

      it 'sends access granted email but not participant change notification to manager' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_granted_email', 'deliver_now',
          { params: { user: manager, collection_version: collection_version }, args: [] }
        ).and not_to_have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'participants_changed_email', anything, anything
        )
      end
    end

    context 'when reviewers are removed from a collection' do
      let(:collection_after) { collection.dup.tap { |col| col.reviewed_by = [collection.reviewed_by.first] } }
      let(:collection) do
        create(:collection, :with_reviewers)
      end

      it 'sends emails to those removed' do
        expect { action }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'CollectionsMailer', 'review_access_removed_email', 'deliver_now',
          { params: { user: collection.reviewed_by.last, collection_version: collection_version }, args: [] }
        )
      end
    end
  end
end
