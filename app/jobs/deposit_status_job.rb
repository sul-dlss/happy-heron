# typed: false
# frozen_string_literal: true

# Wait for a deposit into SDR API.
class DepositStatusJob < BaseDepositJob
  queue_as :default

  sig { params(work: Work, job_id: Integer).void }
  def perform(work:, job_id:)
    result = status(job_id: job_id)
    # This will force a recheck of status (and should be ignored by Honeybadger)
    raise TryAgainLater, "No result yet for job #{job_id}" if result.nil?

    if result.success?
      work.druid = result.value!
      work.deposit_complete!
    else
      Honeybadger.notify("Job #{job_id} for work #{work.id} failed with: #{result.failure}")
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
