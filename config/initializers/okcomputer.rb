# typed: strict
# frozen_string_literal: true

OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# Required
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: Settings.redis_url)

# Optional
OkComputer::Registry.register 'background_jobs', OkComputer::SidekiqLatencyCheck.new('default', 25)

# sdr-api
OkComputer::Registry.register 'sdr_api', OkComputer::HttpCheck.new("#{Settings.sdr_api.url}/status")

OkComputer.make_optional %w[
  sdr_api
  background_jobs
]
