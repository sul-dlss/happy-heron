# frozen_string_literal: true

module Works
  module Edit
    # Displays a single attached file
    class AttachedFileComponent < ApplicationComponent
      def initialize(attached_file:, depth:)
        @attached_file = attached_file
        @depth = depth
      end

      attr_reader :attached_file, :depth

      delegate :basename, :label, :hide?, :in_preservation?, :in_globus?, :file, to: :attached_file

      # @return a link to download the file. If the file is new in this version, then it generates an
      # activeStorage link, otherwise a preservation link.
      def path
        return preservation_path(attached_file) if in_preservation?

        rails_blob_path(file, disposition: 'attachment')
      end

      # the user can get a download link unless the file is in globus (in which case, no download link is available)
      def can_download?
        !in_globus?
      end
    end
  end
end
