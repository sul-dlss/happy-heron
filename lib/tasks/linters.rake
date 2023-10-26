# frozen_string_literal: true

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  task rubocop: :environment do
    abort "Please install the rubocop gem to run rubocop."
  end
end

desc "Run erblint against ERB files"
task :erblint do
  puts "Running erblint..."
  system("bundle exec erblint --lint-all --format compact")
end

desc "Run Yarn linter against JS files"
task :eslint do
  puts "Running JS linters..."
  system("yarn run lint")
end

desc "Run all configured linters"
task lint: %i[rubocop erblint eslint]
