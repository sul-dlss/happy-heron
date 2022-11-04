# frozen_string_literal: true

# Roles are passed to docker-compose as profiles.
server 'h2-docker-qa.stanford.edu', user: 'h2', roles: %w[web app db cron worker]

Capistrano::OneTimeKey.generate_one_time_key!
