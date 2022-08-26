# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

RSpec.describe CollectionReminderGenerator do
  describe '.send_draft_reminders' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managed_by: [user]) }

    context 'when there are collections that need a notification sent' do
      let(:version_draft1) do
        create(:collection_version, :version_draft, created_at: 14.days.ago, collection: collection)
      end
      let(:version_draft2) do
        create(:collection_version, :version_draft, created_at: 42.days.ago, collection: collection)
      end
      # every 28 days from there
      let(:version_draft3) do
        create(:collection_version, :version_draft, created_at: 70.days.ago, collection: collection)
      end

      it 'queues an email for each draft collection that needs a notification sent' do
        expect { described_class.send_draft_reminders }
          .to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with(
            'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
            { params: { collection_version: version_draft1, user: user }, args: [] }
          )
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
                { params: { collection_version: version_draft2, user: user }, args: [] }
              ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
                { params: { collection_version: version_draft3, user: user }, args: [] }
              ))
      end
    end

    context 'with collections in the wrong state, but at the right interval' do
      before do
        create(:collection_version, :depositing, created_at: 14.days.ago)
        create(:collection_version, :deposited, created_at: 14.days.ago)
        create(:collection_version, :first_draft, created_at: 14.days.ago)
      end

      it 'does not queue notifications' do
        expect { described_class.send_draft_reminders }
          .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end

    context "when drafts that aren't on a reminder interval day relative to creation" do
      before do
        create(:collection_version, :version_draft, collection: collection) # right state, wrong interval
      end

      it 'does not queue notifications' do
        expect { described_class.send_draft_reminders }
          .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end
end
