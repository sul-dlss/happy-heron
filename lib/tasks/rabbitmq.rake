namespace :rabbitmq do
  desc "Setup routing"
  task setup: :environment do
    require 'bunny'

    conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                     username: Settings.rabbitmq.username,
                     password: Settings.rabbitmq.password).tap(&:start)

    channel = conn.create_channel

    # connect topic to the queue
    exchange = channel.topic('sdr.workflow')
    queue = channel.queue('h2.deposit_complete', durable: true)
    queue.bind(exchange, routing_key: 'end-accession.completed')

    conn.close
  end
end
