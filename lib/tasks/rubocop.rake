# frozen_string_literal: true

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new do |task|
    task.requires << "rubocop-performance"
    task.requires << "rubocop-rails"
    task.requires << "rubocop-rspec"
  end
rescue LoadError
  task rubocop: :environment do
    abort "Please install the rubocop gem to run rubocop."
  end
end
