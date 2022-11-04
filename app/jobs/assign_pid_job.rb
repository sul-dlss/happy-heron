# frozen_string_literal: true

# Assigns a DRUID and DOI to a model
class AssignPidJob
  include Sneakers::Worker
  # This worker will connect to "h2.druid_assigned" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.druid_assigned_development"
  from_queue Settings.rabbitmq.queues.druid_assigned, env: nil

  def work(msg)
    model = build_cocina_model_from_json_str(msg)
    source_id = model.identification.sourceId
    attrs = case model
            when Cocina::Models::DRO
              { druid: model.externalIdentifier, doi: model.identification.doi }
            else
              { druid: model.externalIdentifier }
            end
    update_attributes_by_source(source_id, **attrs)
    ack!
  end

  def update_attributes_by_source(source_id, args)
    unprefixed = source_id.delete_prefix('hydrus:')
    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      object = if unprefixed.start_with?('object-')
                 Work.find(unprefixed.delete_prefix('object-'))
               else
                 Collection.find(unprefixed.delete_prefix('collection-'))
               end

      object.update(args)

      return unless object.is_a? Work

      object.head.pid_assigned!
    end
  end

  def build_cocina_model_from_json_str(str)
    json = JSON.parse(str)
    Cocina::Models.build(json.fetch('model'))
  end
end
