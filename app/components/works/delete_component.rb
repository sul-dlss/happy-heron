# typed: strict
# frozen_string_literal: true

module Works
  # Renders the widget that allows a user to delete a draft deposit.
  class DeleteComponent < ApplicationComponent
    sig { params(work: Work, style: Symbol).void }
    def initialize(work:, style: :icon)
      @work = work
      @style = style
    end

    sig { returns(Work) }
    attr_reader :work

    sig { returns(T::Boolean) }
    def icon?
      @style == :icon
    end

    sig { returns(T::Boolean) }
    def render?
      helpers.allowed_to?(:delete?, work)
    end
  end
end
