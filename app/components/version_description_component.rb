# typed: true
# frozen_string_literal: true

# Renders a widget for enetering a version description
class VersionDescriptionComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
end


# form.object.model.fetch(:work_version).state