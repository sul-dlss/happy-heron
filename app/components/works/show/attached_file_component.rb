# frozen_string_literal: true

module Works
  module Show
    # Displays a single attached file
    class AttachedFileComponent < ApplicationComponent
      def initialize(attached_file:, work_version:)
        @attached_file = attached_file
        @work_version = work_version
      end

      attr_reader :attached_file

      delegate :label, :hide?, :in_preservation?, to: :attached_file

      # @return a link to download the file. If the file is new in this version, then it generates an
      # activeStorage link, otherwise a preservation link.
      def path
        return preservation_path(attached_file) if in_preservation?

        rails_blob_path(attached_file.file, disposition: 'attachment')
      end

      def filename
        attached_file.path
      end
    end
  end
end
