# typed: false
# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

every :day, at: '1:00am' do
  runner 'WorkReminderGenerator.send_first_draft_reminders'
end
