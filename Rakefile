# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

desc 'Run Continuous Integration Suite (linter and tests)'
task ci: %i[rubocop spec]

# clear the default task injected by rspec
task(:default).clear

# and replace it with our own
task default: :ci
