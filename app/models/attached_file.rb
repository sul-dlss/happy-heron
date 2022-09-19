# frozen_string_literal: true

# Models a File that is attached to a Work
class AttachedFile < ApplicationRecord
  belongs_to :work_version
  has_one_attached :file

  def blob
    file.attachment.blob
  end

  delegate :filename, :content_type, :byte_size, to: :blob

  # This is a temporary method that makes the blobs appear to be from preservation,
  # but it only changes the blob in memory. In the future we may permanently update the
  # blob records after deposit.
  def transform_blob_to_preservation
    file.blob = file.blob.dup
    file.blob.key = create_active_storage_key
    file.blob.service_name = 'preservation'
  end

  def create_active_storage_key
    ActiveStorage::Service::SdrService.encode_key(work_version.work.druid,
                                                  work_version.version,
                                                  filename.to_s)
  end

  def in_preservation?
    work_version.deposited? || !changed_in_this_version?
  end

  private

  def changed_in_this_version?
    previous_version = work_version.previous_version
    return true unless previous_version

    previous_attachement = previous_version.attached_files.find { |af| af.filename == filename }

    blob != previous_attachement # is it a different ActiveStorage::Blob
  end
end
