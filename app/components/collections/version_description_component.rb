# frozen_string_literal: true

module Collections
  # Renders a widget for entering a version description
  class VersionDescriptionComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def collection_version
      form.object.model
    end

    def render?
      %w[deposited rejected version_draft].include? collection_version.state
    end
  end
end
