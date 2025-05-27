# frozen_string_literal: true

module Works
  module Show
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

        file.save unless file.persisted?
        rails_blob_path(file.blob, disposition: 'attachment')
      end

      def stacks_path
        "#{Settings.stacks_file_url}/#{attached_file.work_version.work.druid}/#{attached_file_path}"
      end

      def attached_file_path
        attached_file.path.split('/').map { |part| ERB::Util.url_encode(part) }.join('/')
      end

      # the user can get a download link unless the file is in globus (in which case, no download link is available)
      def can_download?
        !in_globus?
      end

      def can_share?
        !(attached_file.work_version.first_draft? || attached_file.work_version.purl_reserved?)
      end
    end
  end
end
