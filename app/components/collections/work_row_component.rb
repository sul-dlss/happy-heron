# typed: false
# frozen_string_literal: true

module Collections
  # Displays a single table row representing a work in a collection.
  class WorkRowComponent < ApplicationComponent
    with_collection_parameter :work_version

    # sig { params(work_version: WorkVersion).void }
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    # Returns the size of the attached files
    def size
      number_to_human_size(attached_files.sum(&:byte_size))
    end

    delegate :work, :attached_files, to: :work_version
    delegate :allowed_to?, to: :helpers
  end
end
