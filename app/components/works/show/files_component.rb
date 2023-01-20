# frozen_string_literal: true

module Works
  module Show
    # Draws the files section of the show page
    class FilesComponent < ApplicationComponent
      def initialize(work_version:)
        @work_version = work_version
      end

      attr_reader :work_version

      delegate :attached_files, :work, to: :work_version

      def download_all?
        work_version.attached_files.all? { |attached_file| !attached_file.in_globus? }
      end

      # show files only for browser and globus upload_types, not zipfile
      def render?
        work_version.browser? || work_version.globus?
      end

      def spinner
        tag.span class: 'fa-solid fa-spinner fa-pulse fa-2xl my-5'
      end
    end
  end
end
