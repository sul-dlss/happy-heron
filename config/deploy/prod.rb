# frozen_string_literal: true

server "sul-h2-prod.stanford.edu", user: "h2", roles: %w[web app db cron]

Capistrano::OneTimeKey.generate_one_time_key!
