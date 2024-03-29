# frozen_string_literal: true

module Works
  module Edit
    # Displays a folder in the hierarchy for the work edit page
    class DirectoryComponent < ViewComponent::Base
      def initialize(directory:, form:)
        @directory = directory
        @form = form
      end

      delegate :name, :children_directories, :children_files, :depth, :full_path, to: :directory

      def dir_id
        "dir-#{directory.index}"
      end

      attr_reader :directory, :form
    end
  end
end
