# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for selecting a license to apply to the work
  class LicenseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :license, to: :reform

    def reform
      form.object
    end
  end
end
