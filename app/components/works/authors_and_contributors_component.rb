# frozen_string_literal: true

module Works
  # A widget for managing both the ordered authors and unordered contributors to the work.
  # We make this distinction between different types of contributors, because only authors
  # appear in the automatically generated citation.
  class AuthorsAndContributorsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
