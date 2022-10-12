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

    def filesize
      return unless uploaded?

      form.object.model.byte_size
    end

    def date_uploaded
      return unless saved?

      form.object.model.created_at
    end

    # file has been uploaded but may not yet have been saved to the database model (and may not validate)
    def uploaded?
      !form.object.try(:model)&.blob.nil?
    end

    # file has been uploaded and saved to the model
    def saved?
      form.object.persisted?
    end
  end
end
