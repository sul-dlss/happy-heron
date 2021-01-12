# typed: false
# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositStatusJob
  extend T::Sig
  include Sneakers::Worker
  # This worker will connect to "h2.deposit_complete" queue
  # env is set to nil since by default the actuall queue name would be
  # "h2.deposit_complete_development"
  from_queue 'h2.deposit_complete', env: nil

  sig { params(msg: String).void }
  def work(msg)
    json = JSON.parse(msg)
    # TODO: how are we going to match up our request with an object that doesn't yet have a druid.
    # TODO: Maybe have source_id broadcast passed with registration.

    druid = json.fetch('druid')
    object = Work.find_by(druid: druid) || Collection.find_by(druid: druid)
    version = object.head

    complete_deposit(version, json.fetch(:druid))
    ack!
  end

  # Assigns druid, adds the purl to the citation (if one exists), updates the state and saves.
  def complete_deposit(object, druid)
    if object.is_a? WorkVersion
      complete_work_version_deposit(object, druid)
    else
      complete_collection_version_deposit(object, druid)
    end
  end

  private

  sig { params(object: WorkVersion, druid: String).void }
  def complete_work_version_deposit(object, druid)
    object.transaction do
      object.work.druid = druid
      object.add_purl_to_citation
      object.work.save!
      # Force a save because state_machine-activerecord wraps its update in a transaction.
      # The transaction includes the after_transition callbacks, which may enqueue mailer jobs.
      # It's possible the mailer job is started before the transaction in the main thread is completed,
      # which means the mailer may not have access to the druid.
      object.save!
      object.deposit_complete!
    end
  end
<<<<<<< HEAD

  sig { params(object: CollectionVersion, druid: String).void }
  def complete_collection_version_deposit(object, druid)
    object.transaction do
      object.collection.druid = druid
      object.collection.save!
      # Force a save because state_machine-activerecord wraps its update in a transaction.
      # The transaction includes the after_transition callbacks, which may enqueue mailer jobs.
      # It's possible the mailer job is started before the transaction in the main thread is completed,
      # which means the mailer may not have access to the druid.
      object.save!
      object.deposit_complete!
    end
  end

  sig { params(job_id: Integer).returns(T.nilable(Dry::Monads::Result)) }
  def status(job_id:)
    login_result = login
    return login_result unless login_result.success?

    result = SdrClient::BackgroundJobResults.show(url: Settings.sdr_api.url, job_id: job_id)
    if result[:status] != 'complete'
      nil
    elsif result[:output][:errors].present?

      Dry::Monads::Failure(error_msg_for(result[:output][:errors]))
    else
      Dry::Monads::Success(result[:output][:druid])
    end
  end

  def error_msg_for(errors)
    error = errors.first
    error_msg = error[:title]
    error_msg += ": #{error[:message]}" if error[:message]
    error_msg
  end
=======
>>>>>>> Add sneakers to do rabbitmq processing
end
