# typed: true
# frozen_string_literal: true

module Works
  class LicenseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
