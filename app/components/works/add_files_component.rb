# frozen_string_literal: true

module Works
  # The widget that uploads files to active storage and attaches them to the work.
  class AddFilesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def max_upload_files
      Settings.max_upload_files
    end

    def has_attached_files?
      form.object.attached_files.any?
    end

    def browser_option?
      form.object.attached_files.length <= max_upload_files
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
      # Only show checkbox once a new work_version with a cleared out globus_endpoint has been created.
      !form.object.work_version.deposited? && form.object.work_version.globus_endpoint.present?
    end

    def origin_options
      [
        ["Select...", ""],
        ["Stanford Google Drive", "stanford_gdrive"],
        ["Oak", "oak"],
        ["Sherlock", "sherlock"]
      ]
    end
  end
end
