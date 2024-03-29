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
  from_queue 'h2.deposit_complete', env: nil

  FIND_TRIES = 10
  FIND_SLEEP = 1

  # rubocop:disable Metrics/AbcSize
  def work(msg)
    druid = parse_message(msg)
    Honeybadger.context(druid:)
    Rails.logger.info("Trying deposit complete on #{druid}")

    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = find_object(druid)

      unless object
        Rails.logger.info("Not completing deposit for #{druid} since not found")
        return ack!
      end

      Honeybadger.context(object: object.to_global_id.to_s)
      Rails.logger.info("Deposit complete on #{druid}")

      DepositCompleter.complete(object_version: object.head)
    end

    ack!
  end
  # rubocop:enable Metrics/AbcSize

  def parse_message(msg)
    json = JSON.parse(msg)
    druid = json.fetch('druid')
    return druid if druid.present?

    raise "Unable to find required field 'druid' in payload:\n\t#{json}"
  end

  def find_object(druid)
    # There is a race condition whereby the druid may not yet have been assigned to the work / collection.
    # Retries gives time for the druid to be assigned.
    # See https://github.com/sul-dlss/happy-heron/issues/3297
    object = nil
    begin
      tries ||= 1
      object = Work.find_by(druid:) || Collection.find_by!(druid:)
    rescue ActiveRecord::RecordNotFound
      if (tries += 1) <= FIND_TRIES
        sleep(FIND_SLEEP)
        retry
      end
    end
    object
  end
end
