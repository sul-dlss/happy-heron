# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

every :day, at: '1:00am' do
  runner 'WorkReminderGenerator.send_draft_reminders'
end

every :day, at: '1:13am' do
  runner 'CollectionReminderGenerator.send_draft_reminders'
end

# Remove any files that did not get attached to objects after 7 days
every :day, at: '12:00am' do
  rake 'cleanup:uploads'
end
