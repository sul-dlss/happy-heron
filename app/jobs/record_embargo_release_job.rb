# frozen_string_literal: true

# Wait for a deposit into SDR API.
class RecordEmbargoReleaseJob
  include Sneakers::Worker
  # This worker will connect to "h2.embargo_lifted" queue
  # env is set to nil since by default the actual queue name would be
  # "h2.embargo_lifted_development"
  from_queue 'h2.embargo_lifted', env: nil

  def work(msg)
    model = build_cocina_model_from_json_str(msg)
    Honeybadger.context(druid: model.externalIdentifier)

    # Without this, the database connection pool gets exhausted
    ActiveRecord::Base.connection_pool.with_connection do
      work = Work.find_by(druid: model.externalIdentifier)
      work.events.create!(event_type: 'embargo_lifted')
    end
    ack!
  end

  def build_cocina_model_from_json_str(str)
    json = JSON.parse(str)
    Cocina::Models.build(json.fetch('model'))
  end
end
