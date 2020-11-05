# typed: strict
# frozen_string_literal: true

# Custom exception class to special-case exceptions raised in the
# DepositStatusJob related to deposits not yet being done. We use these
# exceptions to signal to Sidekiq to restart the job after incremental backoff.
# The special-casing is helpful because it allows us to ignore these exceptions
# in Honeybadger.
class TryAgainLater < RuntimeError; end
