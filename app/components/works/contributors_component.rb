# typed: strict
# frozen_string_literal: true

module Works
  # A widget for managing the collection of contributors to the work.
  class ContributorsComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder, optional: T::Boolean).void }
    def initialize(form:, optional: false)
      @form = form
      @optional = optional
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form

    sig { returns(T::Boolean) }
    attr_reader :optional
  end
end
