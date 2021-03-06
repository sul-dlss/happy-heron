# typed: false
# frozen_string_literal: true

module Works
  # The widget that uploads files to active storage and attaches them to the work.
  class AddFilesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def error?
      errors.present?
    end

    def error_message
      safe_join(errors.map(&:message), tag.br)
    end

    def errors
      form.object.errors.where(:attached_files)
    end
  end
end
