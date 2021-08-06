# frozen_string_literal: true

module Works
  # Renders a widget corresponding to a single file attached to the work.
  class FileRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def filename
      return unless uploaded?

      form.object.model.filename
    end

    def uploaded?
      form.object.persisted?
    end
  end
end
