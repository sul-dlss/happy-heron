# frozen_string_literal: true

module Works
  # The widget that uploads files to active storage and attaches them to the work.
  class AddFilesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def has_attached_files?
      form.object.attached_files.any?
    end

    def error?
      errors.present?
    end

    def error_message
      safe_join(errors.map(&:message), tag.br)
    end

    def errors
      form.object.errors.where(:attached_files)
    end

    def globus_endpoint?
      form.object.work_version.globus_endpoint.present?
    end
  end
end
