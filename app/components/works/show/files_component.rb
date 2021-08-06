# frozen_string_literal: true

module Works
  module Show
    # Draws the files section of the show page
    class FilesComponent < ApplicationComponent
      def initialize(work_version:)
        @work_version = work_version
      end

      attr_reader :work_version

      delegate :attached_files, to: :work_version
    end
  end
end
