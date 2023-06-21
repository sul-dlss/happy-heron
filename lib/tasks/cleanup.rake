# frozen_string_literal: true

namespace :cleanup do
  desc "Remove unattached files"
  task uploads: :environment do
    # Purge all blob keys were created 7 days ago and do not have attachments
    ActiveStorage::Blob.where.missing(:attachments)
      .where("DATE(active_storage_blobs.created_at) = ?", 7.days.ago.to_date)
      .find_each(&:purge_later)
  end
end
