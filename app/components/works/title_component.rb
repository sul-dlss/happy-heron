# typed: true
# frozen_string_literal: true

module Works
  class TitleComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
