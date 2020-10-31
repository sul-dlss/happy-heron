# typed: false
# frozen_string_literal: true

require 'active_storage/service/disk_service'

# Use a Druid-based disk service
module ActiveStorage
  class Service
    # Provides a druid-based tree path
    class DruidDiskService < DiskService
      private

      def folder_for(key)
        work = ActiveStorage::Blob.find_by(key: key).attachments.first.record.work
        path = DruidTools::Druid.new(work.druid).path
        Rails.logger.info("Moving blob #{key} to #{path}")
        path
      end
    end
  end
end
