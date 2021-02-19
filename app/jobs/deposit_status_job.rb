# typed: false
# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositStatusJob < BaseDepositJob
  queue_as :default

  sig { params(object: T.any(WorkVersion, CollectionVersion), job_id: Integer).void }
  def perform(object:, job_id:)
    result = status(job_id: job_id)
    # This will force a recheck of status (and should be ignored by Honeybadger)
    raise TryAgainLater, "No result yet for job #{job_id}" if result.nil?

    if result.success?
      complete_deposit(object, result.value!)
    else
      Honeybadger.notify("Job #{job_id} for #{object.class} #{object.id} failed with: #{result.failure}")
    end
  end

  # Assigns druid, adds the purl to the citation (if one exists), updates the state and saves.
  def complete_deposit(object, druid)
    if object.is_a? WorkVersion
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
    else
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
  end

  private

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
end
