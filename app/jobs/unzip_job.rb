# frozen_string_literal: true

require 'zip'

# Change work version from a zipfile type to a browser type by unzipping the attached zip file.
class UnzipJob < BaseDepositJob
  queue_as :default

  def perform(work_version)
    zip_attached_file = work_version.attached_files.last
    # Ensure the last file uploaded is actually a ZIP file and is not only in globus.
    # This guards against a user selecting the zip option after having previously uploaded non-zip files
    # but then not actually uploading a zip file OR having a ZIP file but only in globus.
    # Previously this would have resulted im the job getting stuck.
    # See https://github.com/sul-dlss/happy-heron/issues/3454
    # Instead, we want to just revert back to the browser upload style
    # without doing anything else.
    if unzip_file?(zip_attached_file)
      destroy_attached_files_except(zip_attached_file, work_version)
      Zip::File.open(filepath_for(zip_attached_file)) do |zip_file|
        Dir.mktmpdir do |temp_dir|
          zip_file.each do |entry|
            next if ignore?(entry)

            attach_file(entry:, temp_dir:, work_version:)
          end
        end
      end
      zip_attached_file.destroy
    end
    work_version.upload_type = 'browser'
    work_version.unzip_complete!
  end

  private

  # determines if we should actually unzip this file, based on it not being in globus and being a zip file
  def unzip_file?(zip_attached_file)
    !zip_attached_file.in_globus? && zip_attached_file.zip?
  end

  def destroy_attached_files_except(except_attached_file, work_version)
    work_version.attached_files.excluding(except_attached_file).destroy_all
  end

  def ignore?(entry)
    !entry.file? || IgnoreFileService.ignore?(entry.name)
  end

  def filepath_for(attached_file)
    ActiveStorage::Blob.service.path_for(attached_file.blob.key)
  end

  def attach_file(entry:, temp_dir:, work_version:)
    temp_filepath = File.join(temp_dir, entry.name)
    FileUtils.mkdir_p(File.dirname(temp_filepath))
    entry.extract(temp_filepath)

    work_version.attached_files << AttachedFile.new(path: entry.name).tap do |attached_file|
      attached_file.file.attach(io: File.open(temp_filepath), filename: entry.name)
    end

    FileUtils.rm(temp_filepath)
  end
end
