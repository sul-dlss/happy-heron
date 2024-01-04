# frozen_string_literal: true

OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# Required
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new
OkComputer::Registry.register 'redis', OkComputer::RedisCheck.new(url: ENV.fetch('REDIS_URL', Settings.redis_url))

# Check that RabbitMQ queues exist
class RabbitQueueExistsCheck < OkComputer::Check
  attr_reader :queue_names, :conn

  def initialize(queue_names)
    @queue_names = Array(queue_names)
    @conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                      vhost: Settings.rabbitmq.vhost,
                      username: Settings.rabbitmq.username,
                      password: Settings.rabbitmq.password)
    super()
  end

  # rubocop:disable Metrics/AbcSize
  def check
    conn.start
    status = conn.status
    missing_queue_names = queue_names.reject { |queue_name| conn.queue_exists?(queue_name) }
    if missing_queue_names.empty?
      mark_message "'#{queue_names.join(', ')}' exists, connection status: #{status}"
    else
      mark_message "'#{missing_queue_names.join(', ')}' does not exist"
      mark_failure
    end
    conn.close
  rescue StandardError => e
    mark_message "Error: '#{e}'"
    mark_failure
  end
  # rubocop:enable Metrics/AbcSize
end

if Settings.rabbitmq.enabled
  OkComputer::Registry.register 'rabbit-queues',
                                RabbitQueueExistsCheck.new(['h2.deposit_complete', 'h2.druid_assigned',
                                                            'h2.embargo_lifted'])
end

# Optional
OkComputer::Registry.register 'background_jobs', OkComputer::SidekiqLatencyCheck.new('default', 25)
OkComputer::Registry.register 'sdr_api', OkComputer::HttpCheck.new("#{Settings.sdr_api.url}/status")

OkComputer.make_optional %w[
  sdr_api
  background_jobs
]
