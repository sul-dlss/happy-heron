# typed: strict
# frozen_string_literal: true

module Works
  # Renders the widget that allows a user to delete a draft deposit.
  class DeleteComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work

    sig { returns(T::Boolean) }
    def render?
      helpers.allowed_to?(:delete?, work)
    end
  end
end
