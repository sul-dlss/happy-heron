# frozen_string_literal: true

# Models a File that is attached to a Work
class AttachedFile < ApplicationRecord
  belongs_to :work_version
  has_one_attached :file

  delegate :blob, to: :file
  delegate :filename, :content_type, :byte_size, to: :blob

  def path
    # Stubbing out for the future in which this may contain the path, not just the filename.
    filename.to_s
  end

  # This is a temporary method that makes the blobs that haven't yet been updated
  # appear to be from preservation, but it only changes the blob in memory.
  # Currently we permanently update the blob records after deposit and in the future we will remediate
  # all the deposited blobs, so this method will be unnecessary.
  def transform_blob_to_preservation
    return if ActiveStorage::Service::SdrService.accessible?(file.blob)

    file.blob = file.blob.dup
    file.blob.key = create_active_storage_key
    file.blob.service_name = ActiveStorage::Service::SdrService::SERVICE_NAME
  end

  def create_active_storage_key
    ActiveStorage::Service::SdrService.encode_key(work_version.work.druid,
                                                  work_version.version,
                                                  filename.to_s)
  end

  # Is the most recently uploaded copy of this file in preservation?
  def in_preservation?
    ActiveStorage::Service::SdrService.accessible?(file.blob) ||
      work_version.deposited? ||
      !changed_in_this_version?
  end

  private

  def changed_in_this_version?
    previous_version = work_version.previous_version
    return true unless previous_version

    previous_attachement = previous_version.attached_files.find { |af| af.filename == filename }

    blob != previous_attachement # is it a different ActiveStorage::Blob
  end
end
