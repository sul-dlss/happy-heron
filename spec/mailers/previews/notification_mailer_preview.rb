# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def reject_email
    work = Work.first
    NotificationMailer.with(user: work.depositor, work: work).reject_email
  end

  def approved_email
    work = Work.first
    NotificationMailer.with(user: work.depositor, work: work).approved_email
  end

  def new_version_deposited_email
    work = Work.first
    NotificationMailer.with(user: work.depositor, work: work).new_version_deposited_email
  end

  def deposited_email
    work = Work.first
    NotificationMailer.with(user: work.depositor, work: work).deposited_email
  end
end
