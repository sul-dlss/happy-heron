# frozen_string_literal: true

module Works
  module Edit
    # Displays the list of files available to edit in the work edit page
    class FilesComponent < ViewComponent::Base
      def initialize(work_version:)
        @work_version = work_version
      end

      attr_reader :work_version

      def root_directory
        FileHierarchyService.to_hierarchy(work_version:)
      end
    end
  end
end
