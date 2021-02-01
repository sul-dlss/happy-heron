# typed: strict
# frozen_string_literal: true

module Works
  # A widget for managing the collection of contributors to the work.
  class AuthorsComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form
  end
end
