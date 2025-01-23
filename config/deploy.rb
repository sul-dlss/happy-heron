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

# Default value for :linked_files is []
append :linked_files,
       'config/database.yml', # in Puppet
       'config/secrets.yml', # in shared_configs
       'config/honeybadger.yml' # in shared_configs

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'config/settings', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

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

# Manage sidekiq via systemd (from dlss-capistrano gem)
set :sidekiq_systemd_use_hooks, true

# Manage sneakers via systemd (from dlss-capistrano gem)
set :sneakers_systemd_use_hooks, true

namespace :rabbitmq do
  desc 'Runs rake rabbitmq:setup'
  task setup: ['deploy:set_rails_env'] do
    on roles(fetch(:sneakers_systemd_role)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'rabbitmq:setup'
        end
      end
    end
  end

  before 'sneakers_systemd:start', 'rabbitmq:setup'
end

# Set Rails env to production in all Cap environments
set :rails_env, 'production'

# Deploy passenger-standalone via systemd service
set :passenger_restart_command, 'sudo systemctl restart passenger'
set :passenger_restart_options, -> { '' }

set :whenever_environment, fetch(:rails_env)
set :whenever_roles, [:cron]

# update shared_configs before restarting app (from dlss-capistrano gem)
before 'deploy:restart', 'shared_configs:update'
