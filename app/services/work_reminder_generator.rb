# typed: strict
# frozen_string_literal: true

# This creates and queues reminder emails for in-progress drafts
class WorkReminderGenerator
  extend T::Sig

  # Sends the day's reminders about open first drafts, using default values for the notification
  # interval unless the caller overrides the defaults with custom values. Intended to be run daily
  # by a cron job, but the optional manual override for notification interval is useful in case a
  # human has to manually call the method to send dropped notifications, e.g. in the event that
  # something goes awry with the cron job on a particular day. For example, if the cron job got
  # wedged 2 days ago, you could call this method with the the default values plus 2.
  # @note Intervals are specified in days.
  sig { params(first_interval: T.nilable(Integer), subsequent_interval: T.nilable(Integer)).void }
  def self.send_first_draft_reminders(first_interval: nil, subsequent_interval: nil)
    first_interval ||= Settings.notifications.first_draft_reminder.first_interval
    subsequent_interval ||= Settings.notifications.first_draft_reminder.subsequent_interval

    eligible_works(first_interval, subsequent_interval).find_each do |work|
      WorksMailer.with(work: work)
                 .first_draft_reminder_email.deliver_later
    end
  end

  sig { params(first_interval: Integer, subsequent_interval: Integer).returns(ActiveRecord::Relation) }
  private_class_method def self.eligible_works(first_interval, subsequent_interval)
    Work
      .with_state(:first_draft)
      .where('(((CURRENT_DATE - CAST(updated_at AS DATE)) - :first_interval) % :subsequent_interval) = 0',
             first_interval: first_interval, subsequent_interval: subsequent_interval)
  end
end
