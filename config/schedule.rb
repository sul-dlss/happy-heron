# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever
require 'config'

Config.load_and_set_settings(Config.setting_files('config', 'production'))

# These define jobs that checkin with Honeybadger.
# If changing the schedule of one of these jobs, also update at https://app.honeybadger.io/projects/77112/check_ins
job_type :rake_hb,
         'cd :path && :environment_variable=:environment bundle exec rake :task --silent :output && ' \
         "curl 'https://api.honeybadger.io/v1/check_in/:check_in"
job_type :runner_hb,
         "cd :path && bin/rails runner -e :environment ':task' && " \
         "curl 'https://api.honeybadger.io/v1/check_in/:check_in' :output"

every :day, at: '1:00am' do
  set :check_in, Settings.honeybadger_checkins.work_reminder
  runner_hb 'WorkReminderGenerator.send_draft_reminders'
end

every :day, at: '1:13am' do
  set :check_in, Settings.honeybadger_checkins.collection_reminder
  runner_hb 'CollectionReminderGenerator.send_draft_reminders'
end

# Remove any files that did not get attached to objects after 7 days
every :day, at: '12:00am' do
  set :check_in, Settings.honeybadger_checkins.uploads_cleaner
  rake_hb 'cleanup:uploads'
end
