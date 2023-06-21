# frozen_string_literal: true

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new do |task|
    task.requires << "standard"
    task.requires << "rubocop-performance"
    task.requires << "rubocop-rails"
    task.requires << "rubocop-rspec"
    task.requires << "rubocop-capybara"
    task.requires << "rubocop-factory_bot"
  end
rescue LoadError
  task rubocop: :environment do
    abort "Please install the rubocop gem to run rubocop."
  end
end

task :erblint do
  puts "Running erblint..."
  `erblint --lint-all --format compact`
end
