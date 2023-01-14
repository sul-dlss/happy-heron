# frozen_string_literal: true

module Works
  module Edit
    # Displays a single attached file
    class AttachedFileComponent < ApplicationComponent
      def initialize(attached_file:, depth:, form:)
        @attached_file = attached_file
        @depth = depth
        @form = form
      end

      attr_reader :attached_file, :depth, :form

      delegate :basename, to: :attached_file

      # file has been uploaded but may not yet have been saved to the database model (and may not validate)
      def uploaded?
        !attached_file.blob.nil?
      end
    end
  end
end
