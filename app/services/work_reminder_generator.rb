# typed: strict
# frozen_string_literal: true

# This creates and queues reminder emails for in-progress drafts
class WorkReminderGenerator
  extend T::Sig

  NILABLE_DURATION = T.type_alias { T.nilable(ActiveSupport::Duration) }

  # Sends the day's reminders about open first drafts, using default values for the notification
  # interval unless the caller overrides the defaults with custom values. Intended to be run daily
  # by a cron job, but the optional manual override for notification interval is useful in case a
  # human has to manually call the method to send dropped notifications, e.g. in the event that
  # something goes awry with the cron job on a particular day. For example, if the cron job got
  # wedged 2 days ago, you could call this method with the the default values plus 2.
  sig { params(first_interval: NILABLE_DURATION, subsequent_interval: NILABLE_DURATION).void }
  def self.send_first_draft_reminders(first_interval: nil, subsequent_interval: nil)
    first_interval ||= Settings.notifications.first_draft_reminder.first_interval.days
    subsequent_interval ||= Settings.notifications.first_draft_reminder.subsequent_interval.days

    eligible_works(first_interval).find_each do |work|
      if send_first_draft_reminder?(work, first_interval, subsequent_interval)
        WorksMailer.with(work: work)
                   .first_draft_reminder_email.deliver_later
      end
    end
  end

  sig do
    params(work: Work, first_interval: ActiveSupport::Duration, subsequent_interval: ActiveSupport::Duration)
      .returns(T::Boolean)
  end
  private_class_method def self.send_first_draft_reminder?(work, first_interval, subsequent_interval)
    # this will also work if today is the first reminder day, because it'll be 0 % 0
    return true if (days_since_first_reminder(work, first_interval) % subsequent_interval).to_i.zero?

    false
  end

  sig { params(work: Work, first_interval: ActiveSupport::Duration).returns(ActiveSupport::Duration) }
  private_class_method def self.days_since_first_reminder(work, first_interval)
    today = DateTime.now.utc.beginning_of_day
    first_reminder_day = work.updated_at.utc.beginning_of_day.to_datetime + first_interval
    (today - first_reminder_day).seconds
  end

  sig { params(first_interval: ActiveSupport::Duration).returns(ActiveRecord::Relation) }
  private_class_method def self.eligible_works(first_interval)
    # every notification we send will be at least first_interval days ago
    cutoff_date = DateTime.now.utc.end_of_day - first_interval
    Work.with_state(:first_draft).where(updated_at: ..cutoff_date)
  end
end
