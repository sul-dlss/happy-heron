# frozen_string_literal: true

module Works
  module Show
    # Displays a folder in the hierarchy for the work show page
    class DirectoryComponent < ViewComponent::Base
      def initialize(directory:)
        @directory = directory
      end

      delegate :name, :children_directories, :children_files, :depth, to: :directory

      attr_reader :directory
    end
  end
end
