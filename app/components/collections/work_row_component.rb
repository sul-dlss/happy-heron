# frozen_string_literal: true

module Collections
  # Displays a single table row representing a work in a collection.
  class WorkRowComponent < ApplicationComponent
    with_collection_parameter :work_version

    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    # Returns the size of the attached files
    def size
      # Note: This direct SQL query avoids excessive queries for large objects,
      # Otherwise multiple queries to ActiveRecord are performed for each file
      # to get it's size.
      number_to_human_size(AttachedFile.where(work_version_id: work_version.id)
                           .joins("INNER JOIN active_storage_attachments on active_storage_attachments.record_id = attached_files.id")
                           .joins("INNER JOIN active_storage_blobs on active_storage_attachments.blob_id = active_storage_blobs.id")
                           .where("active_storage_attachments.record_type" => "AttachedFile")
                           .sum("byte_size"))
    end

    delegate :work, :attached_files, to: :work_version
  end
end
