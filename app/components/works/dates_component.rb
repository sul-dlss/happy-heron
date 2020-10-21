# typed: true
# frozen_string_literal: true

module Works
  class DatesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
