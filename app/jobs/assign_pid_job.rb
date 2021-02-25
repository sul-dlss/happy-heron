# typed: false
# frozen_string_literal: true

# Assigns a druid to a model
class AssignPidJob
  extend T::Sig
  include Sneakers::Worker
  # This worker will connect to "h2.druid_assigned" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.druid_assigned_development"
  from_queue 'h2.druid_assigned', env: nil

  sig { params(msg: String).returns(Symbol) }
  def work(msg)
    json = JSON.parse(msg)

    model = Cocina::Models.build(json.fetch('model'))
    source_id = model.identification&.sourceId
    Honeybadger.context(source_id: source_id)
    return ack! unless source_id&.start_with?('hydrus:')

    assign_druid(source_id, model.externalIdentifier)
    ack!
  end

  def assign_druid(source_id, druid)
    unprefixed = source_id.delete_prefix('hydrus:')
    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = if unprefixed.start_with?('object-')
                 Work.find(unprefixed.delete_prefix('object-'))
               else
                 Collection.find(unprefixed.delete_prefix('collection-'))
               end

      object.update(druid: druid)

      return unless object.is_a? Work

      object.head.add_purl_to_citation
    end
  end
end
