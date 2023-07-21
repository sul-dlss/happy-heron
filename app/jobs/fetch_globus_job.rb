# frozen_string_literal: true

require "zip"

# Change work version from a globus type to a browser type by fetching file names
# from Globus and creating Attached Files.
class FetchGlobusJob < BaseDepositJob
  queue_as :default

  def perform(work_version)
    work_version.attached_files.destroy_all
    files = files_for(work_version)

    # Since it can take a while (hours) to get the filepaths from Globus API for large
    # deposits we need to ensure that we still have an active database connection
    # before trying to use it again or else we can get an error:
    # PG::UnableToSend: SSL SYSCALL error: EOF detected
    ActiveRecord::Base.clear_active_connections!

    files.each do |file|
      next if ignore?(file.name)

      work_version.attached_files << new_attached_file(file, work_version)
    end
    work_version.upload_type = "browser"
    work_version.fetch_globus_complete!
  end

  def files_for(work_version)
    GlobusClient
      .list_files(path: work_version.globus_endpoint, user_id: work_version.work.owner.email)
      .map do |file|
        file.tap { file.name = file.name.delete_prefix(work_version.globus_endpoint_fullpath) }
      end
  end

  def ignore?(path)
    path.start_with?("__MACOSX") || path.end_with?(".DS_Store")
  end

  def new_attached_file(file, work_version)
    AttachedFile.new(path: file.name, work_version:).tap do |attached_file|
      blob = ActiveStorage::Blob.create_before_direct_upload!(
        key: attached_file.create_globus_active_storage_key,
        filename: file.name,
        service_name: ActiveStorage::Service::GlobusService::SERVICE_NAME,
        byte_size: file.size,
        checksum: file.name
      )
      attached_file.file.attach(blob)
    end
  end
end
