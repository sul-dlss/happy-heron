# typed: strict
# frozen_string_literal: true

module Works
  # A widget for managing both the ordered authors and unordered contributors to the work.
  # We make this distinction between different types of contributors, because only authors
  # appear in the automatically generated citation.
  class AuthorsAndContributorsComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form
  end
end
