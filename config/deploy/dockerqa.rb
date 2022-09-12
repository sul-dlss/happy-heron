# frozen_string_literal: true

server 'h2-docker-qa.stanford.edu', user: 'h2', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!

set :rails_env, 'production'

# Disable unneeded tasks
ENV['SKIP_UPDATE_STRSCAN'] = 'true'
set :rvm_roles, []
set :bundle_roles, []
set :assets_roles, []
set :migration_role, nil
set :passenger_roles, []
#  honeybager:deploy doesn't work because no ruby/bundler on server.
Rake::Task['honeybadger:deploy'].clear_actions
# No config/database.yml since using env variables
set :linked_files, %w[config/secrets.yml config/honeybadger.yml]
set :linked_dirs, %w[log config/settings]
# Manage sidekiq via systemd (from dlss-capistrano gem)
set :sidekiq_systemd_use_hooks, false
# Manage sneakers via systemd (from dlss-capistrano gem)
set :sneakers_systemd_use_hooks, false

# Most of below can be moved to tasks in dlss/capistrano
before 'deploy:cleanup', 'shared_configs:update'
set(:docker_compose_file, 'docker-compose.prod.yml')
set :dereference_files, fetch(:linked_files)
set :dereference_dirs, %w[config/settings]
after 'shared_configs:symlink', 'docker_compose:build'
after 'deploy:publishing', 'docker_compose:migrate'
after 'deploy:publishing', 'docker_compose:copy_assets'
after 'deploy:publishing', 'docker_compose:seed'
after 'deploy:publishing', 'docker_compose:setup_rabbitmq'
after 'deploy:starting', 'docker:login'
# Cleaning up docker on start so that images/logs are available for troubleshooting.
after 'deploy:starting', 'docker:prune'
after 'deploy:cleanup', 'docker:logout'
after 'deploy:published', 'docker_compose:restart'
after 'deploy:finishing', 'honeybadger:notify'

# rubocop:disable Metrics/BlockLength
namespace :docker_compose do
  desc 'Build images'
  task :build do
    on roles(:app) do
      # Docker build does not dereference symlinks.
      invoke 'docker_compose:dereference_linked_files'
      invoke 'docker_compose:dereference_linked_dirs'
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'build')
      end
      info 'Docker images built'
    end
  end

  desc 'Migrate database'
  task :migrate do
    on roles(:db) do
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'run', 'app', 'bin/rails',
                'db:migrate')
      end
      info 'Db migrated'
    end
  end

  desc 'Seed database'
  task :seed do
    on roles(:db) do
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'run', 'app', 'bin/rails',
                'db:seed')
      end
      info 'Db migrated'
    end
  end

  desc 'Copy assets'
  task :copy_assets do
    on roles(:web) do
      within current_path do
        # Can't do a direct copy to public/assets because it is a symlink.
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'cp',
                'app:/app/public/assets', '.')
        execute(:rm, '-fr', 'public/assets/*')
        execute(:cp, 'assets/*', 'public/assets/')
      end
      info 'Assets copied'
    end
  end

  desc 'Setup RabbitMQ'
  task :setup_rabbitmq do
    on roles(:web) do
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'run', 'app', 'bin/rake',
                'rabbitmq:setup')
      end
      info 'RabbitMQ setup'
    end
  end

  desc 'Restart containers (down then up)'
  task :restart do
    on roles(:app) do
      within current_path do
        info 'Restarting containers'
        invoke 'docker_compose:down'
        invoke 'docker_compose:up'
      end
    end
  end

  desc 'Start containers'
  task :up do
    on roles(:app) do
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'up', '-d')
        info 'Containers started'
      end
    end
  end

  desc 'Tear down containers'
  task :down do
    on roles(:app) do
      within current_path do
        execute(:docker, 'compose', '-f', fetch(:docker_compose_file, 'docker-compose.yml'), 'down')
        info 'Containers down'
      end
    end
  end

  desc 'Dereference linked files'
  task :dereference_linked_files do
    next unless any? :dereference_files

    on roles(:app) do
      fetch(:dereference_files).each do |file|
        target = release_path.join(file)
        source = shared_path.join(file)
        execute :rm, target if test "[ -L #{target} ]"
        execute :cp, source, target
      end
    end
  end

  desc 'Dereference linked directories'
  task :dereference_linked_dirs do
    next unless any? :dereference_dirs

    on roles(:app) do
      fetch(:dereference_dirs).each do |dir|
        target = release_path.join(dir)
        source = shared_path.join(dir)
        next unless test "[ -L #{target} ]"

        execute :rm, target
        execute :cp, '-r', source, target
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

namespace :docker do
  desc 'Log in to Docker Hub'
  task :login do
    on roles(:app) do
      within current_path do
        execute(:docker, 'login', '-u', '$DOCKER_USERNAME', '-p', '$DOCKER_PASSWORD')
      end
    end
  end

  desc 'Log out of Docker Hub'
  task :logout do
    on roles(:app) do
      within current_path do
        execute(:docker, 'logout')
      end
    end
  end

  desc 'Prune unused images/containers'
  task :prune do
    on roles(:app) do
      within current_path do
        execute(:docker, 'image', 'prune', '-f')
        execute(:docker, 'container', 'prune', '-f')
      end
    end
  end
end

namespace :honeybadger do
  # Replaces honeybadger:deploy to use curl instead of invoking ruby.
  # Adapted from https://github.com/honeybadger-io/honeybadger-ruby/blob/master/vendor/capistrano-honeybadger/lib/capistrano/tasks/deploy.cap
  desc 'Notify Honeybadger of a deploy (using the API via curl)'
  task notify: %i[env deploy:set_current_revision] do
    if (server = fetch(:honeybadger_server))
      revision = fetch(:current_revision)

      on server do |_host|
        info 'Notifying Honeybadger of deploy.'

        honeybadger_config = nil
        within release_path do
          honeybadger_config = capture(:cat, 'config/honeybadger.yml')
        end
        remote_api_key = YAML.safe_load(honeybadger_config)['api_key']

        options = {
          'deploy[environment]' => fetch(:honeybadger_env, fetch(:rails_env, 'production')),
          'deploy[local_username]' => fetch(:honeybadger_user, ENV['USER'] || ENV.fetch('USERNAME', nil)),
          'deploy[revision]' => revision,
          'deploy[repository]' => fetch(:repo_url),
          'api_key' => fetch(:honeybadger_api_key, ENV.fetch('HONEYBADGER_API_KEY', nil)) || remote_api_key
        }
        data = options.to_a.map { |pair| pair.join('=') }.join('&')
        execute(:curl, '--no-progress-meter', '--data', "\"#{data}\"", 'https://api.honeybadger.io/v1/deploys')
        info 'Honeybadger notification complete.'
      end
    end
  end
end
