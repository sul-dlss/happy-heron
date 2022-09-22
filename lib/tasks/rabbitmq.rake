# frozen_string_literal: true

namespace :rabbitmq do
  desc 'Setup routing'
  task setup: :environment do
    require 'bunny'

    conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                     vhost: Settings.rabbitmq.vhost,
                     username: Settings.rabbitmq.username,
                     password: Settings.rabbitmq.password).tap(&:start)

    channel = conn.create_channel

    # connect topic to the queue
    exchange = channel.topic('sdr.workflow')
    queue = channel.queue(Settings.rabbitmq.queues.deposit_complete, durable: true)
    queue.bind(exchange, routing_key: 'end-accession.completed')

    exchange = channel.topic('sdr.objects.created')
    queue = channel.queue(Settings.rabbitmq.queues.druid_assigned, durable: true)
    queue.bind(exchange, routing_key: Settings.h2.project_tag)

    exchange = channel.topic('sdr.objects.embargo_lifted')
    queue = channel.queue(Settings.rabbitmq.queues.embargo_lifted, durable: true)
    queue.bind(exchange, routing_key: Settings.h2.project_tag)
    conn.close
  end
end
