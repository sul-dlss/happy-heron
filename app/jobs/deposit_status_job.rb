# typed: false
# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositStatusJob
  extend T::Sig
  include Sneakers::Worker
  # This worker will connect to "h2.deposit_complete" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.deposit_complete_development"
  from_queue 'h2.deposit_complete', env: nil

  sig { params(msg: String).void }
  def work(msg)
    json = JSON.parse(msg)
    druid = json.fetch('druid')
    raise "Unable to find required field 'druid' in payload:\n\t#{json}" if druid.blank?

    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = Work.find_by(druid: druid) || Collection.find_by(druid: druid)
      return ack! unless object # could be an object from a different project

      object.head.deposit_complete!
    end
    ack!
  end
end
