# frozen_string_literal: true

# This creates and queues reminder emails for in-progress work drafts
class WorkReminderGenerator
  # Sends the day's reminders about open work drafts, using default values for the notification
  # interval unless the caller overrides the defaults with custom values. Intended to be run daily
  # by a cron job, but the optional manual override for notification interval is useful in case a
  # human has to manually call the method to send dropped notifications, e.g. in the event that
  # something goes awry with the cron job on a particular day. For example, if the cron job got
  # wedged 2 days ago, you could call this method with the the default values plus 2.
  # @note Intervals are specified in days.

  def self.send_draft_reminders
    first_interval = Settings.notifications.first_draft_reminder.first_interval
    subsequent_interval = Settings.notifications.first_draft_reminder.subsequent_interval

    eligible_works(first_interval, subsequent_interval).each do |state, scope|
      scope.find_each do |work_version|
        mailer = WorksMailer.with(work_version:)
        case state
        when :first_draft
          mailer.first_draft_reminder_email.deliver_later
        when :version_draft
          mailer.new_version_reminder_email.deliver_later
        end
      end
    end
  end

  private_class_method def self.eligible_works(first_interval, subsequent_interval)
    %i[first_draft version_draft].index_with do |state|
      WorkVersion.with_state(state)
        .where("(((CURRENT_DATE - CAST(created_at AS DATE)) - :first_interval) % :subsequent_interval) = 0",
          first_interval:, subsequent_interval:)
    end
  end
end
