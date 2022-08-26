# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

RSpec.describe CollectionReminderGenerator do
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '.send_draft_reminders' do
    let(:collection_a) { create(:collection_version, :depositing) }
    let(:collection_b) { create(:collection_version, :deposited) }
    let(:version_draft1) { create(:collection_version, :version_draft) }
    let(:version_draft2) { create(:collection_version, :version_draft, created_at: 3.days.ago) }
    let(:version_draft3) { create(:collection_version, :version_draft, created_at: 7.days.ago) }
    let(:version_draft4) do
      create(:collection_version, :version_draft, created_at: 14.days.ago)
    end
    let(:version_draft5) { create(:collection_version, :version_draft, created_at: 28.days.ago) }
    let(:version_draft6) do
      create(:collection_version, :version_draft, created_at: 42.days.ago)
    end
    let(:version_draft7) { create(:collection_version, :version_draft, created_at: 47.days.ago) }
    # every 28 days from there
    let(:version_draft8) do
      create(:collection_version, :version_draft, created_at: 70.days.ago)
    end
    let(:first_draft1) { create(:collection_version, :first_draft) }
    let(:first_draft2) { create(:collection_version, :first_draft, created_at: 3.days.ago) }
    let(:first_draft3) { create(:collection_version, :first_draft, created_at: 7.days.ago) }
    let(:first_draft4) do
      create(:collection_version, :first_draft, created_at: 14.days.ago)
    end
    let(:first_draft5) { create(:collection_version, :first_draft, created_at: 28.days.ago) }
    let(:first_draft6) do
      create(:collection_version, :first_draft, created_at: 42.days.ago)
    end
    let(:first_draft7) { create(:collection_version, :first_draft, created_at: 47.days.ago) }
    let(:first_draft8) { create(:collection_version, :first_draft, created_at: 70.days.ago) } # every 28 days from there

    it 'queues an email for each draft collection that needs a notification sent' do
      expect { described_class.send_draft_reminders }
        .to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
          { params: { collection_version: first_draft4 }, args: [] }
        )
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
              { params: { collection_version: first_draft6 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
              { params: { collection_version: first_draft8 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
              { params: { collection_version: version_draft4 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
              { params: { collection_version: version_draft6 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', 'deliver_now',
              { params: { collection_version: version_draft8 }, args: [] }
            ))
    end

    it 'does not queue notifications for collections in the wrong state' do
      expect { described_class.send_draft_reminders }
        .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'CollectionsMailer', 'draft_reminder_email', anything,
          { params: { collection_version: collection_a }, args: anything }
        )
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: collection_b }, args: anything }
            ))
    end

    it "does not queue notifications for drafts that aren't on a reminder interval day relative to creation" do
      expect { described_class.send_draft_reminders }
        .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'CollectionsMailer', 'draft_reminder_email', anything,
          { params: { collection_version: first_draft1 }, args: anything }
        )
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: first_draft2 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: first_draft3 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: first_draft5 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: first_draft7 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: version_draft1 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: version_draft2 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: version_draft3 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: version_draft5 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'draft_reminder_email', anything,
              { params: { collection_version: version_draft7 }, args: anything }
            ))
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
