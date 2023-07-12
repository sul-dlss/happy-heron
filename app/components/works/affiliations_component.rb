# frozen_string_literal: true

module Works
  # A widget for managing the collection of affiliations to the contributor/author.
  class AffiliationsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
