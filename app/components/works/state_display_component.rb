# typed: false
# frozen_string_literal: true

module Works
  # Displays information about the current state of the deposit
  class StateDisplayComponent < ApplicationComponent
    sig { params(work_version: WorkVersion).void }
    def initialize(work_version:)
      @work_version = work_version
    end

    sig { returns(WorkVersion) }
    attr_reader :work_version

    sig { returns(T.nilable(String)) }
    def call
      value = I18n.t(work_version.state, scope: 'work.state')
      return value unless work_version.depositing? || work_version.reserving_purl?

      safe_join([value, spinner], ' ')
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end
  end
end
