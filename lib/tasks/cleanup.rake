# frozen_string_literal: true

require "logger"

namespace :cleanup do
  desc "Remove unattached files"
  task uploads: :environment do
    # Purge all blob keys were created 7 days ago and do not have attachments
    ActiveStorage::Blob.where.missing(:attachments)
      .where("DATE(active_storage_blobs.created_at) = ?", 7.days.ago.to_date)
      .find_each(&:purge_later)
  end

  desc "Update zero length files"
  task file_sizes: :environment do
    logger = Logger.new($stdout)

    # Find druids that have zero length files in active storage and update them
    # using the file size from SDR.
    sql =
      <<-SQL
      SELECT 
        druid,
        work_versions.id AS work_version_id,
        active_storage_blobs.filename AS filename,
        active_storage_blobs.id AS blob_id
      FROM works
      JOIN work_versions ON work_versions.work_id = works.id
      JOIN attached_files ON attached_files.work_version_id = work_versions.id
      JOIN active_storage_attachments ON active_storage_attachments.record_id = attached_files.id
      JOIN active_storage_blobs ON active_storage_blobs.id = active_storage_attachments.blob_id
      WHERE active_storage_blobs.byte_size = 0 
        AND druid IS NOT NULL;
      SQL

    # update the blob with the filesize from the SDR
    objects = {}
    ActiveRecord::Base.connection.execute(sql).each do |result|
      # look up the druid if we haven't seen it already
      if !objects.has_key?(result["druid"])
        begin
          objects[result["druid"]] = Repository.find(result["druid"])
        rescue RuntimeError
          logger.error("Unable to lookup %{result['druid']} in SDR")
          next
        end
      end
      object = objects[result["druid"]]

      # find the file in the structural metadata
      sdr_file = nil
      object.structural.contains.each do |fileset|
        sdr_file ||= fileset.structural.contains.find { |file| file.filename == result["filename"] }
      end

      # update the blob!
      if sdr_file
        blob = ActiveStorage::Blob.find(result["blob_id"])
        if blob.byte_size == 0
          blob.byte_size = sdr_file.size
          blob.save
          logger.info(%(updated blob #{blob.id} size to #{sdr_file.size} for #{result["druid"]}))
        else
          logger.error(%(blob #{blob.id} for #{result["druid"]} doesn't have zero byte size!))
        end
      else
        logger.error(%(couldn't find #{result["filename"]} for #{result["druid"]}))
      end
    end
  end
end
