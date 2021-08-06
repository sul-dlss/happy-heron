# frozen_string_literal: true

conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                 vhost: Settings.rabbitmq.vhost,
                 username: Settings.rabbitmq.username,
                 password: Settings.rabbitmq.password)
Sneakers.configure connection: conn
Sneakers.logger.level = Logger::INFO
Sneakers.error_reporters << proc { |exception, _worker, context_hash| Honeybadger.notify(exception, context_hash) }
