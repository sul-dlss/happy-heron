# frozen_string_literal: true

# Models a File that is attached to a Work
class AttachedFile < ApplicationRecord
  belongs_to :work_version
  has_one_attached :file

  def path
    super || blob&.filename.to_s
  end

  delegate :blob, to: :file
  delegate :filename, :content_type, :byte_size, :checksum, to: :blob

  # This is a temporary method that makes the blobs that haven't yet been updated
  # appear to be from preservation, but it only changes the blob in memory.
  # Currently we permanently update the blob records after deposit and in the future we will remediate
  # all the deposited blobs, so this method will be unnecessary.
  def transform_blob_to_preservation
    return if ActiveStorage::Service::SdrService.accessible?(file.blob)

    file.blob = file.blob.dup
    file.blob.key = create_preservation_active_storage_key
    file.blob.service_name = ActiveStorage::Service::SdrService::SERVICE_NAME
  end

  def create_preservation_active_storage_key
    ActiveStorage::Service::SdrService.encode_key(work_version.work.druid,
                                                  work_version.version,
                                                  path)
  end

  def create_globus_active_storage_key
    ActiveStorage::Service::GlobusService.encode_key(work_version.work.id,
                                                     work_version.version,
                                                     path)
  end

  # Is the most recently uploaded copy of this file in preservation?
  def in_preservation?
    ActiveStorage::Service::SdrService.accessible?(file.blob) ||
      work_version.deposited? ||
      !changed_in_this_version?
  end

  def in_globus?
    ActiveStorage::Service::GlobusService.accessible?(file.blob)
  end

  def zip?
    zip_mime_types.include?(content_type)
  end

  # an array of directorie(s) that contain this file; e.g. ['folder','sub-folder']
  # if there are no containing directories, it will be an empty array; eg []
  def paths
    path.split(File::SEPARATOR)[...-1]
  end

  # a string containing the base filename, removing any containing directories if they exist; e.g. 'test.pdf'
  def basename
    path.split(File::SEPARATOR).last
  end

  # @return [String nil] the MD5 checksum in hexadecimal format or nil if in globus
  def md5
    return if in_globus?

    Base64.decode64(checksum).unpack1('H*')
  end

  private

  def zip_mime_types
    ['application/zip', 'application/x-zip-compressed', 'application/x-zip', 'multipart/x-zip']
  end

  def changed_in_this_version?
    previous_version = work_version.previous_version
    return true unless previous_version

    previous_attachement = previous_version.attached_files.find { |af| af.filename == filename }

    blob != previous_attachement # is it a different ActiveStorage::Blob
  end
end
