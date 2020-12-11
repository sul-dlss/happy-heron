# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

RSpec.describe WorkReminderGenerator do
  describe '.send_first_draft_reminders' do
    let(:work_a) { create(:work, :pending_approval) }
    let(:work_b) { create(:work, :depositing) }
    let(:work_c) { create(:work, :deposited) }
    let(:work_d) { create(:work, :rejected) }
    let(:work_e) { create(:work, :version_draft) }
    let(:work1) { create(:work, :first_draft) }
    let(:work2) { create(:work, :first_draft, updated_at: 3.days.ago) }
    let(:work3) { create(:work, :first_draft, updated_at: 7.days.ago) }
    let(:work4) { create(:work, :first_draft, updated_at: 14.days.ago) } # 1st reminder at 14 days by default
    let(:work5) { create(:work, :first_draft, updated_at: 28.days.ago) }
    let(:work6) { create(:work, :first_draft, updated_at: 42.days.ago) } # then 2nd reminder 28 days after 1st
    let(:work7) { create(:work, :first_draft, updated_at: 47.days.ago) }
    let(:work8) { create(:work, :first_draft, updated_at: 70.days.ago) } # every 28 days from there

    it 'queues an email for each draft work that needs a notification sent' do
      expect { described_class.send_first_draft_reminders }
        .to(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work4 }, args: [] }
            )
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work6 }, args: [] }
            ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work8 }, args: [] }
            )))
    end

    it 'does not queue notifications for works in the wrong state' do
      expect { described_class.send_first_draft_reminders }
        .to(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work_a }, args: anything }
            )
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work_b }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work_c }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work_d }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work_e }, args: anything }
            )))
    end

    it "does not queue notifications for drafts that aren't on a reminder interval day relative to creation" do
      expect { described_class.send_first_draft_reminders }
        .to(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work1 }, args: anything }
            )
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work2 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work3 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work5 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work7 }, args: anything }
            )))
    end

    it 'allows the caller to override the default reminder intervals' do
      expect { described_class.send_first_draft_reminders(first_interval: 3, subsequent_interval: 4) }
        .to(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work2 }, args: [] }
            )
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work3 }, args: [] }
            ))
            .and(have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', 'deliver_now',
              { params: { work: work7 }, args: [] }
            )))

      expect { described_class.send_first_draft_reminders(first_interval: 3.days, subsequent_interval: 4.days) }
        .to(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work1 }, args: anything }
            )
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work4 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work5 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work6 }, args: anything }
            ))
            .and(not_have_enqueued_job(ActionMailer::MailDeliveryJob)
            .with(
              'WorksMailer', 'first_draft_reminder_email', anything,
              { params: { work: work8 }, args: anything }
            )))
    end
  end
end
