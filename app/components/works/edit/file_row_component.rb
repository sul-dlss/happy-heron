# frozen_string_literal: true

module Works
  module Edit
    # Renders a widget corresponding to a single file attached to the work.
    class FileRowComponent < ApplicationComponent
      def initialize(form:, zip_template: false, path: nil)
        @form = form
        @zip_template = zip_template
        @path = path
      end

      attr_reader :form, :path

      # file has been uploaded but may not yet have been saved to the database model (and may not validate)
      def uploaded?
        !form.object.try(:model)&.blob.nil?
      end

      # file has been uploaded and saved to the model
      def saved?
        form.object.persisted?
      end

      def zip_template?
        @zip_template
      end
    end
  end
end
