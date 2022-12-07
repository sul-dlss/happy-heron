# frozen_string_literal: true

# Handles Globus setup actions (create endpoints if possible, send emails)
class GlobusSetupJob < ApplicationJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize
  def perform(work_version)
    druid = work_version.work.druid # may be nil
    depositor_sunet = work_version.work.depositor.sunetid
    Honeybadger.context({ work_version_id: work_version.id, druid:,
                          work_id: work_version.work.id, depositor_sunet: })

    if glubus_user_exists?(depositor_sunet) && work_version.globus_endpoint.blank?
      # user is known to globus but doesn't have a globus endpoint yet, so create it and send the email
      create_globus_endpoint(work_version)
      send_email_with_globus_endpoint(work_version)
      work_version.globus_setup_complete! # this transitions the state back to draft (first of verion)
    elsif !glubus_user_exists?(depositor_sunet) && work_version.draft?
      # user is NOT known to globus, and is not yet in the globus_setup state:
      # this means they need to complete their globus account activation first and then let us know,
      #  so put them into the globus pending state, which will then send them an email (via the state transition)
      work_version.globus_setup_pending! # this transitions the state from draft to globus_setup
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def glubus_user_exists?(depositor_sunet)
    Globus::Client.user_exists?(depositor_sunet)
  end

  def create_globus_endpoint(work_version)
    result = Globus::Client.mkdir(user_id: work_version.work.depositor.sunetid, work_id: work_version.work.id,
                                  work_version: work_version.id)
    work_version.update(globus_endpoint: result)
  end

  def send_email_with_globus_endpoint(work_version)
    # send email instructions to user with globus endpoint
    WorksMailer.with(user: work_version.work.owner, work_version:).globus_endpoint_created
  end
end
