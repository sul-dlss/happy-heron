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

  sig { params(msg: String).void }
  def work(msg)
    json = JSON.parse(msg)
    model = Cocina::Models.build(json.fetch('model'))
    source_id = model.identification.sourceId

    return unless source_id.start_with?('hydrus:')


    object = Work.find(source_id.delete_prefix('hydrus:'))
    object.druid = druid
    object.add_purl_to_citation if object.respond_to?(:add_purl_to_citation)
    object.save!
    ack!
  end
end
