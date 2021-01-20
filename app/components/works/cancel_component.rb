# typed: strict
# frozen_string_literal: true

module Works
  # Renders the widget that allows a user to cancel an edit in progress.
  class CancelComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work
  end
end
