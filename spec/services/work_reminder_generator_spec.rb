# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

RSpec.describe WorkReminderGenerator do
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '.send_draft_reminders' do
    let(:work_a) { create(:work_version, :pending_approval) }
    let(:work_b) { create(:work_version, :depositing) }
    let(:work_c) { create(:work_version, :deposited) }
    let(:work_d) { create(:work_version, :rejected) }
    let(:version_draft1) { create(:work_version, :version_draft) }
    let(:version_draft2) { create(:work_version, :version_draft, created_at: 3.days.ago) }
    let(:version_draft3) { create(:work_version, :version_draft, created_at: 7.days.ago) }
    let(:version_draft4) do
      create(:work_version, :version_draft, created_at: 14.days.ago)
    end
    let(:version_draft5) { create(:work_version, :version_draft, created_at: 28.days.ago) }
    let(:version_draft6) do
      create(:work_version, :version_draft, created_at: 42.days.ago)
    end
    let(:version_draft7) { create(:work_version, :version_draft, created_at: 47.days.ago) }
    let(:version_draft8) { create(:work_version, :version_draft, created_at: 70.days.ago) } # every 28 days from there
    let(:first_draft1) { create(:work_version, :first_draft) }
    let(:first_draft2) { create(:work_version, :first_draft, created_at: 3.days.ago) }
    let(:first_draft3) { create(:work_version, :first_draft, created_at: 7.days.ago) }
    let(:first_draft4) { create(:work_version, :first_draft, created_at: 14.days.ago) } # 1st reminder at 14 days by default
    let(:first_draft5) { create(:work_version, :first_draft, created_at: 28.days.ago) }
    let(:first_draft6) { create(:work_version, :first_draft, created_at: 42.days.ago) } # then 2nd reminder 28 days after 1st
    let(:first_draft7) { create(:work_version, :first_draft, created_at: 47.days.ago) }
    let(:first_draft8) { create(:work_version, :first_draft, created_at: 70.days.ago) } # every 28 days from there

    it 'queues an email for each draft work that needs a notification sent' do
      expect { described_class.send_draft_reminders }
        .to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
          { params: { work_version: first_draft4 }, args: [] }
        )
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work_version: first_draft6 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work_version: first_draft8 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'new_version_reminder_email', 'deliver_now',
              { params: { work_version: version_draft4 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'new_version_reminder_email', 'deliver_now',
              { params: { work_version: version_draft6 }, args: [] }
            ))
        .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'new_version_reminder_email', 'deliver_now',
              { params: { work_version: version_draft8 }, args: [] }
            ))
    end

    it 'does not queue notifications for works in the wrong state' do
      expect { described_class.send_draft_reminders }
        .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'WorksMailer', 'first_draft_reminder_email', anything,
          { params: { work_version: work_a }, args: anything }
        )
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: work_b }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: work_c }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: work_d }, args: anything }
            ))
    end

    it "does not queue notifications for drafts that aren't on a reminder interval day relative to creation" do
      expect { described_class.send_draft_reminders }
        .to not_have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with(
          'WorksMailer', 'first_draft_reminder_email', anything,
          { params: { work_version: first_draft1 }, args: anything }
        )
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: first_draft2 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: first_draft3 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: first_draft5 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: first_draft7 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: version_draft1 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: version_draft2 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: version_draft3 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: version_draft5 }, args: anything }
            ))
        .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work_version: version_draft7 }, args: anything }
            ))
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
