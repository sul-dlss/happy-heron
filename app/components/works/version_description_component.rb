# frozen_string_literal: true

module Works
  # Renders a widget for entering a version description
  class VersionDescriptionComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def work_version
      form.object.model.fetch(:work_version)
    end

    def show?
      %w[deposited rejected version_draft].include? work_version.state
    end

    def hidden_user_version?
      !Settings.user_versions_ui_enabled || !show?
    end
  end
end
