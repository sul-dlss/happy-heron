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

    if user_is_known_to_globus?(depositor_sunet) && work_version.globus_endpoint.blank?
      # user is known to globus but doesn't have an endpoint yet
      create_globus_endpoint(work_version)
      send_email_with_globus_endpoint(work_version)
    elsif !user_is_known_to_globus?(depositor_sunet) && work_version.draft?
      # user is NOT known to globus, and is not yet in the globus_setup state,
      #  so put them into the pending state, which will then send them an email (via the state transition)
      work_version.globus_setup_pending! # this transitions the state from draft to globus_setup
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def user_is_known_to_globus?(_depositor_sunet)
    # TODO: use globus client gem to see if this sunet is known to globus, return true/false
    false
  end

  def create_globus_endpoint(work_version)
    # depositor_sunet = work_version.work.depositor.sunetid
    # TODO use globus client gem to create globus endpoint for this work_version/depositor
    # then store endpoint URL in work_version
    endpoint_url = 'some_globus_string'
    work_version.update(globus_endpoint: endpoint_url)
  end

  def send_email_with_globus_endpoint(work_version)
    # send email instructions to user with globus endpoint
    WorksMailer.with(user: work_version.work.owner, work_version:).globus_endpoint_created
  end
end
