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
      (%w[deposited version_draft].include? work_version.state) || version_review_state?
    end

    def hidden_user_version?
      !Settings.user_versions_ui_enabled || !show?
    end

    def version_review_state?
      (work_version.rejected? || work_version.pending_approval?) && work_version.version > 1
    end
  end
end
