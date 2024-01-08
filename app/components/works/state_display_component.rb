# frozen_string_literal: true

module Works
  # Displays information about the current state of the deposit
  class StateDisplayComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    def call
      value = I18n.t(work_version.state, scope: 'work.state')
      return value.html_safe unless work_version.wait_state? # rubocop:disable Rails/OutputSafety

      safe_join([value, spinner], ' ')
    end

    def spinner
      tag.span class: 'fa-solid fa-spinner fa-pulse'
    end
  end
end
