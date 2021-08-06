# frozen_string_literal: true

server 'sul-h2-qa.stanford.edu', user: 'h2', roles: %w[web app db]

Capistrano::OneTimeKey.generate_one_time_key!
