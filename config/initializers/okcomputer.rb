# typed: true
# frozen_string_literal: true

OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

class TablesHaveDataCheck < OkComputer::Check
  extend T::Sig
  sig { returns(String) }
  def check
    msg = [
      Collection
    ].map { |klass| table_check(klass) }.join(' ')
    mark_message msg
  end

  private

  def table_check(klass)
    # has at least 1 record
    return "#{klass.name} has data." if klass.any?

    mark_failure
    "#{klass.name} has no data."
  rescue => e # rubocop:disable Style/RescueStandardError
    mark_failure
    "#{e.class.name} received: #{e.message}."
  end
end

# Required
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: Settings.redis_url)

OkComputer::Registry.register 'feature-tables-have-data', TablesHaveDataCheck.new

# Optional
OkComputer::Registry.register 'background_jobs', OkComputer::SidekiqLatencyCheck.new('default', 25)

# sdr-api
OkComputer::Registry.register 'sdr_api', OkComputer::HttpCheck.new("#{Settings.sdr_api.url}/status")

OkComputer.make_optional %w[
  sdr_api
  background_jobs
]
