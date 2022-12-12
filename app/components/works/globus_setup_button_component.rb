# frozen_string_literal: true

module Works
  # Renders the globus setup button for a work
  class GlobusSetupButtonComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    def render?
      work_version.globus_setup_draft?
    end
  end
end
