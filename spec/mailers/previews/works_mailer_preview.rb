# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
# Preview these emails at http://localhost:3000/rails/mailers/works_mailer
class WorksMailerPreview < ActionMailer::Preview
  delegate :reject_email, to: :mailer_with_work

  delegate :approved_email, to: :mailer_with_work

  delegate :new_version_deposited_email, to: :mailer_with_work

  delegate :deposited_email, to: :mailer_with_work

  delegate :submitted_email, to: :mailer_with_work

  private

  def mailer_with_work
    work = Work.first
    WorksMailer.with(user: work.depositor, work:)
  end

  def first_draft_reminder_email
    work = Work.first
    WorksMailer.with(work:).first_draft_reminder_email
  end
end
