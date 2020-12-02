# typed: strict
# frozen_string_literal: true

module Works
  # Displays information about the current state of the deposit
  class StateDisplayComponent < ApplicationComponent
    STATE_DISPLAY_LABELS = T.let(
      {
        'first_draft' => 'Draft - Not deposited',
        'version_draft' => 'New version draft - Not deposited',
        'pending_approval' => 'Pending approval - Not deposited',
        'rejected' => 'Returned',
        'depositing' => 'Deposit in progress <span class="fas fa-spinner fa-pulse"></span>'.html_safe,
        'deposited' => 'Deposited'
      }.freeze,
      T::Hash[String, String]
    )

    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work

    sig { returns(T.nilable(String)) }
    def call
      STATE_DISPLAY_LABELS.fetch(work.state)
    end
  end
end
