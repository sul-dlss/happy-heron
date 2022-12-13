# frozen_string_literal: true

# Server hostname is prefixed with "x" to prevent accidental deploy while frozen.
server 'xsul-h2-prod.stanford.edu', user: 'h2', roles: %w[web app db cron]

Capistrano::OneTimeKey.generate_one_time_key!
