# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositCompleteJob
  include Sneakers::Worker
  # This worker will connect to "h2.deposit_complete" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.deposit_complete_development"

  # It is possible that this deposit event was initiated outside of h2. For
  # example, if the embargo was lifted, DSA would open and close a version. The
  # workflow message "end-accession" would end up here.  We must be able to handle
  # these messages in addition to those that result from depositing in h2.
  from_queue Settings.rabbitmq.queues.deposit_complete, env: nil

  def work(msg)
    druid = parse_message(msg)
    Honeybadger.context(druid:)

    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = Work.find_by(druid:) || Collection.find_by(druid:)

      return ack! unless object

      Honeybadger.context(object: object.to_global_id.to_s)

      DepositCompleter.complete(object_version: object.head)
    end

    ack!
  end

  def parse_message(msg)
    json = JSON.parse(msg)
    druid = json.fetch('druid')
    return druid if druid.present?

    raise "Unable to find required field 'druid' in payload:\n\t#{json}"
  end
end
