# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

RSpec.describe CollectionReminderGenerator do
  describe '.send_draft_reminders' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managed_by: [user]) }

    context 'when there are collections that need a notification sent' do
      let(:version_draft4) do
        create(:collection_version, :version_draft, created_at: 14.days.ago, collection:)
      end
      let(:version_draft6) do
        create(:collection_version, :version_draft, created_at: 42.days.ago, collection:)
      end
      # every 28 days from there
      let(:version_draft8) do
        create(:collection_version, :version_draft, created_at: 70.days.ago, collection:)
      end
      let(:first_draft4) do
        create(:collection_version, :first_draft, created_at: 14.days.ago, collection:)
      end
      let(:first_draft6) do
        create(:collection_version, :first_draft, created_at: 42.days.ago, collection:)
      end
      # every 28 days from there
      let(:first_draft8) do
        create(:collection_version, :first_draft, created_at: 70.days.ago, collection:)
      end

      it 'queues an email for each draft collection that needs a notification sent' do
        expect { described_class.send_draft_reminders }
          .to have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with(
            'CollectionsMailer', 'first_draft_reminder_email', 'deliver_now',
            { params: { collection_version: first_draft4, user: }, args: [] }
          )
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'first_draft_reminder_email', 'deliver_now',
                { params: { collection_version: first_draft6, user: }, args: [] }
              ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'first_draft_reminder_email', 'deliver_now',
                { params: { collection_version: first_draft8, user: }, args: [] }
              ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
                { params: { collection_version: version_draft4, user: }, args: [] }
              ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
                { params: { collection_version: version_draft6, user: }, args: [] }
              ))
          .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'new_version_reminder_email', 'deliver_now',
                { params: { collection_version: version_draft8, user: }, args: [] }
              ))
      end
    end

    context 'with collections in the wrong state, but at the right interval' do
      let(:collection_depositing) do
        create(:collection_version, :depositing, created_at: 14.days.ago, collection:)
      end
      let(:collection_deposited) do
        create(:collection_version, :deposited, created_at: 14.days.ago, collection:)
      end

      it 'does not queue notifications' do
        expect { described_class.send_draft_reminders }
          .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with(
            'CollectionsMailer', 'first_draft_reminder_email', anything,
            { params: { collection_version: collection_depositing, user: }, args: anything }
          )
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
              .with(
                'CollectionsMailer', 'first_draft_reminder_email', anything,
                { params: { collection_version: collection_deposited, user: }, args: anything }
              ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'new_version_reminder_email', anything,
              { params: { collection_version: collection_deposited, user: }, args: anything }
            ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'CollectionsMailer', 'new_version_reminder_email', anything,
              { params: { collection_version: collection_deposited, user: }, args: anything }
            ))
      end
    end

    context "when drafts that aren't on a reminder interval day relative to creation" do
      let(:version_draft1) { create(:collection_version, :version_draft, collection:) }
      let(:version_draft2) do
        create(:collection_version, :version_draft, created_at: 3.days.ago, collection:)
      end
      let(:version_draft3) do
        create(:collection_version, :version_draft, created_at: 7.days.ago, collection:)
      end
      let(:version_draft5) do
        create(:collection_version, :version_draft, created_at: 28.days.ago, collection:)
      end
      let(:version_draft7) do
        create(:collection_version, :version_draft, created_at: 47.days.ago, collection:)
      end

      let(:first_draft1) { create(:collection_version, :first_draft, collection:) }
      let(:first_draft2) { create(:collection_version, :first_draft, created_at: 3.days.ago, collection:) }
      let(:first_draft3) { create(:collection_version, :first_draft, created_at: 7.days.ago, collection:) }
      let(:first_draft5) do
        create(:collection_version, :first_draft, created_at: 28.days.ago, collection:)
      end
      let(:first_draft7) do
        create(:collection_version, :first_draft, created_at: 47.days.ago, collection:)
      end

      it 'does not queue notifications' do
        expect { described_class.send_draft_reminders }
          .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
          .with(
            'CollectionsMailer', 'first_draft_reminder_email', anything,
            { params: { collection_version: first_draft1, user: }, args: anything }
          )
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'first_draft_reminder_email', anything,
        { params: { collection_version: first_draft2, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'first_draft_reminder_email', anything,
        { params: { collection_version: first_draft3, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'first_draft_reminder_email', anything,
        { params: { collection_version: first_draft5, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'first_draft_reminder_email', anything,
        { params: { collection_version: first_draft7, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'new_version_reminder_email', anything,
        { params: { collection_version: version_draft1, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'new_version_reminder_email', anything,
        { params: { collection_version: version_draft2, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'new_version_reminder_email', anything,
        { params: { collection_version: version_draft3, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'new_version_reminder_email', anything,
        { params: { collection_version: version_draft5, user: }, args: anything }
      ))
          .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
      .with(
        'CollectionsMailer', 'new_version_reminder_email', anything,
        { params: { collection_version: version_draft7, user: }, args: anything }
      ))
      end
    end
  end
end
