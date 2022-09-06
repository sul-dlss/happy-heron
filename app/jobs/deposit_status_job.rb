# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositStatusJob
  include Sneakers::Worker
  # This worker will connect to "h2.deposit_complete" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.deposit_complete_development"

  # It is possible that this deposit event was initiated outside of h2. For
  # example, if the embargo was lifted, DSA would open and close a version. The
  # workflow message "end-accession" would end up here.  We must be able to handle
  # these messages in addition to those that result from depositing in h2.
  from_queue 'h2.deposit_complete', env: nil

  # rubocop:disable Metrics/AbcSize
  def work(msg)
    druid = parse_message(msg)
    Honeybadger.context(druid: druid)

    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = Work.find_by(druid: druid) || Collection.find_by(druid: druid)

      unless object && object.head.depositing? # rubocop:disable Style/SafeNavigation
        # This guards against objects from a different project and prevents
        # invalid transitions where the workflow was kicked off outside of h2.
        return ack!
      end

      Honeybadger.context(object: object.to_global_id.to_s)

      what_changed = object.head.version_description.presence || 'not specified'
      parent(object).event_context = { user: sdr_user, description: "What changed: #{what_changed}" }

      object.head.deposit_complete!
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

  def parent(object)
    # Though object and object.head.collection/object.head.work are the same in DB, they are not the same in memory.
    # Thus, need to set event_context on the traversed parent object.
    object.head.try(:collection) || object.head.work
  end

  def sdr_user
    User.find_by!(name: 'SDR')
  end
end
