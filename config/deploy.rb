# frozen_string_literal: true

set :application, 'happy-heron'
set :repo_url, 'ssh://git@github.com/sul-dlss/happy-heron.git'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/app/h2/#{fetch(:application)}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

set :linked_files, %w[config/honeybadger.yml]

set :linked_dirs, %w[log config/settings]

set :dereference_dirs, %w[config/settings]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# honeybadger_env otherwise defaults to rails_env
set :honeybadger_env, fetch(:stage)

# Set Rails env to production in all Cap environments
set :rails_env, 'production'

set :docker_compose_file, 'docker-compose.prod.yml'
set :docker_compose_seed_use_hooks, true
set :docker_compose_rabbitmq_use_hooks, true
