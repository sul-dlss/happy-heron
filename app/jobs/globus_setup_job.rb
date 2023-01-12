# frozen_string_literal: true

# Handles Globus setup actions (create endpoints if possible, send emails)
class GlobusSetupJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform(work_version)
    druid = work_version.work.druid # may be nil
    user = work_version.work.owner
    Honeybadger.context({ work_version_id: work_version.id, druid:,
                          work_id: work_version.work.id, depositor_sunet: user.sunetid })

    if globus_user_exists?(user.email) && work_version.globus_endpoint.blank?
      # user is known to globus but doesn't have a globus endpoint yet, so create it and send the email
      create_globus_endpoint(work_version)
      WorksMailer.with(user: work_version.work.owner, work_version:).globus_endpoint_created.deliver_later # send email
      work_version.globus_setup_complete! # this transitions the state back to draft (first draft or version draft)
    elsif !globus_user_exists?(user.email) && work_version.draft?
      # user is NOT known to globus, and is not yet in the globus_setup state:
      # this means they need to complete their globus account activation first and then let us know,
      #  so put them into the globus pending state, which will then send them an email (via the state transition)
      work_version.globus_setup_pending! # this transitions the state from draft to globus_setup
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def globus_user_exists?(user_id)
    return Settings.globus.test_user_exists if fake_globus_calls?

    GlobusClient.user_exists?(user_id)
  end

  def create_globus_endpoint(work_version)
    user = work_version.work.owner
    # e.g. 'mjgiarlo/work1234/version1'
    endpoint_path = format(WorkVersion::GLOBUS_ENDPOINT_TEMPLATE,
                           user_id: user.sunetid,
                           work_id: work_version.work.id,
                           work_version: work_version.version)

    # if simulated globus calls, return success, else make globus client call
    success = fake_globus_calls? ? true : GlobusClient.mkdir(user_id: user.email, path: endpoint_path)

    raise "Error creating globus endpoint for work ID #{work.id}" unless success

    work_version.update(globus_endpoint: endpoint_path)
  end

  # simulate globus calls in development if settings indicate we should for testing
  def fake_globus_calls?
    Settings.globus.test_mode && Rails.env.development?
  end
end
