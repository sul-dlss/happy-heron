# typed: false
# frozen_string_literal: true

module Works
  # Displays information about the current state of the deposit
  class StateDisplayComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work

    sig { returns(T.nilable(String)) }
    def call
      value = I18n.t(work.state, scope: 'work.state')
      return value unless work.depositing?

      safe_join([value, spinner], ' ')
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end
  end
end
