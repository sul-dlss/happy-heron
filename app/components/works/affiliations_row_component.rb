# frozen_string_literal: true

module Works
  # Add a single affiliation to an author / contributor.
  class AffiliationsRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
