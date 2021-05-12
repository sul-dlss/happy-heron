# typed: false
# frozen_string_literal: true

# TODO: add the 'cron' environment when we roll out in production
server 'sul-h2-prod.stanford.edu', user: 'h2', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!
