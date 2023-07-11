# frozen_string_literal: true

module Works
  # Renders the globus setup message and button for a work
  class GlobusSetupComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    def render?
      work_version.globus? && work_version.globus_endpoint
    end

    def globus_user_valid?
      return true if integration_test_mode?
      return Settings.globus.test_user_valid if test_mode?

      GlobusClient.user_valid?(work_version.work.owner.email)
    end

    def integration_test_mode?
      Settings.globus.integration_mode
    end

    # simulate globus calls in development if settings indicate we should for testing
    def test_mode?
      Settings.globus.test_mode && Rails.env.development?
    end

    def endpoint
      url = "https://app.globus.org/file-manager?&destination_id=#{Settings.globus.transfer_endpoint_id}&destination_path=#{Settings.globus.uploads_directory}#{work_version.globus_endpoint}"
      url += "&origin_id=#{Settings.globus.origins[work_version.globus_origin]}" if work_version.globus_origin
      url
    end
  end
end
