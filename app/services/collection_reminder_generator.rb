# frozen_string_literal: true

# This creates and queues reminder emails for in-progress collection drafts
class CollectionReminderGenerator
  # Sends the day's reminders about open collection drafts, using default values for the notification
  # interval unless the caller overrides the defaults with custom values. Intended to be run daily
  # by a cron job, but the optional manual override for notification interval is useful in case a
  # human has to manually call the method to send dropped notifications, e.g. in the event that
  # something goes awry with the cron job on a particular day. For example, if the cron job got
  # wedged 2 days ago, you could call this method with the the default values plus 2.
  # @note Intervals are specified in days.

  def self.send_draft_reminders
    first_interval = Settings.notifications.first_draft_reminder.first_interval
    subsequent_interval = Settings.notifications.first_draft_reminder.subsequent_interval

    eligible_collections(first_interval, subsequent_interval).each do |_state, scope|
      scope.find_each do |collection_version|
        mailer = CollectionsMailer.with(collection_version: collection_version)
        mailer.draft_reminder_email.deliver_later
      end
    end
  end

  private_class_method def self.eligible_collections(first_interval, subsequent_interval)
    query = '(((CURRENT_DATE - CAST(created_at AS DATE)) - :first_interval) % :subsequent_interval) = 0'
    %i[first_draft version_draft].index_with do |state|
      CollectionVersion.with_state(state)
                       .where(query, first_interval: first_interval, subsequent_interval: subsequent_interval)
    end
  end
end
