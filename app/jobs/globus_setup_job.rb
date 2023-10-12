# frozen_string_literal: true

# Handles Globus setup actions (create endpoints if possible, send emails)
class GlobusSetupJob < ApplicationJob
  queue_as :default

  discard_on ActiveJob::DeserializationError

  def perform(work_version)
    druid = work_version.work.druid # may be nil
    user = work_version.work.owner
    Honeybadger.context({work_version_id: work_version.id, druid:,
                          work_id: work_version.work.id, depositor_sunet: user.sunetid,
                          state: work_version.state})

    # user has a valid status in globus but doesn't have a globus endpoint yet, so create it and send the email
    if globus_user_valid?(user.email) && work_version.globus_endpoint.blank?
      # Create endpoint whether or not user has logged into Globus for the first time
      create_globus_endpoint(work_version)
      WorksMailer.with(user: work_version.work.owner, work_version:).globus_endpoint_created.deliver_later # send email
    elsif !globus_user_valid?(user.email)
      raise "Globus username #{user.email} is not a valid Globus account. Not creating globus endpoint for work ID #{work_version.work.id}"
    end
  end

  private

  def globus_user_valid?(user_id)
    return true if integration_test_mode?
    return Settings.globus.test_user_valid if test_mode?

    GlobusClient.user_valid?(user_id)
  end

  def create_globus_endpoint(work_version)
    user = work_version.work.owner
    # e.g. 'mjgiarlo/work1234/version1'
    endpoint_path = endpoint_path_for(work_version, user)

    # if simulated globus calls, return success, else make globus client call
    success = make_dir(user, endpoint_path)

    raise "Error creating globus endpoint for work ID #{work.id}" unless success

    work_version.update(globus_endpoint: endpoint_path)
  end

  def endpoint_path_for(work_version, user)
    return integration_endpoint if integration_test_work_version?(work_version)

    format(WorkVersion::GLOBUS_ENDPOINT_TEMPLATE,
      user_id: user.sunetid,
      work_id: work_version.work.id,
      work_version: work_version.version)
  end

  def make_dir(user, path)
    return true if test_mode?
    return true if integration_test_mode? && path == integration_endpoint

    GlobusClient.mkdir(user_id: user.email, path:, notify_email: false)
  end

  # simulate globus calls in development if settings indicate we should for testing
  def test_mode?
    Settings.globus.test_mode && Rails.env.development?
  end

  def integration_test_mode?
    Settings.globus.integration_mode
  end

  def integration_test_work_version?(work_version)
    integration_test_mode? && work_version.title&.ends_with?("Integration Test")
  end

  def integration_endpoint
    Settings.globus.integration_endpoint
  end
end
