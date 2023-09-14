# frozen_string_literal: true

module Wokes
  # Renders a widget for describing (abstract, keywords, citation, etc.) a work.
  class DescriptionComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
