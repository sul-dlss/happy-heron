# frozen_string_literal: true

module Works
  # Displays information about the current state of the deposit
  class DetailStateDisplayComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    def call
      value = I18n.t(work_version.state, scope: 'work.state')
      return value unless work_version.wait_state?

      if work_version.fetching_globus_state?
        message = 'Transferring your files from Globus. This could take some time depending on file size.
                  You may leave this page or close this window and return later.'
        tag.span(message, class: 'globus-wait')
      else
        safe_join([value, spinner], ' ')
      end
    end

    def spinner
      tag.span class: 'fa-solid fa-spinner fa-pulse'
    end
  end
end
