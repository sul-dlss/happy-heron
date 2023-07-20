# frozen_string_literal: true

module Works
  # A widget for managing the collection of affiliations to the contributor/author.
  class AffiliationsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    # NOTE: July 20 2023 Affiliations are not working correctly due to issues with nested forms and reform.
    # Do not render the control until we correct this.
    # see https://github.com/sul-dlss/happy-heron/issues/3285
    def render?
      false
    end
  end
end
