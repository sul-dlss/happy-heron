# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  # @raise [SdrClient::Find::Failed] if the (non-nil) druid cannot be found in SDR
  def perform(work_version)
    Honeybadger.context({ work_version_id: work_version.id, druid: work_version.work.druid,
                          work_id: work_version.work.id, depositor_sunet: work_version.work.depositor.sunetid })

    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version: work_version)

    perform_login

    new_request_dro = update_dro_with_file_identifiers(request_dro, work_version)

    case new_request_dro
    when Cocina::Models::RequestDRO
      create(new_request_dro, work_version)
    when Cocina::Models::DRO
      update(new_request_dro, work_version)
    end
  end

  private

  def perform_login
    login_result = login
    raise login_result.failure unless login_result.success?
  end

  def update_dro_with_file_identifiers(request_dro, work_version)
    # Only uploading new or changed files
    filenames_to_upload = filenames_to_upload_for(work_version)
    blobs_to_upload = blobs_for(work_version, filenames_to_upload)
    upload_responses = perform_upload(blobs_to_upload)
    # Update with any exteralIdentifiers already assigned to files in SDR.
    new_request_dro = update_dro_with_existing_file_identifiers(request_dro, work_version.work.druid)
    # Update with any new externalIdentifiers assigned by SDR API during upload.
    SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: new_request_dro,
                                                            upload_responses: upload_responses)
  end

  def update_dro_with_existing_file_identifiers(request_dro, druid)
    return request_dro unless druid

    # Map of MD5 to external identifier
    existing_file_identifier_map = existing_file_identifier_map_for(druid)
    new_structural_contains = request_dro.structural.contains.map(&:to_h)
    new_structural_contains.each do |file_set|
      file_set[:structural][:contains].each do |file|
        md5 = md5_for_cocina_file(file)
        file[:externalIdentifier] = existing_file_identifier_map[md5] if existing_file_identifier_map.key?(md5)
      end
    end
    request_dro.new(structural: request_dro.structural.new(contains: new_structural_contains))
  end

  def create(new_request_dro, work_version)
    SdrClient::Deposit::CreateResource.run(accession: true,
                                           assign_doi: work_version.work.assign_doi?,
                                           metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection: connection)
  end

  def update(new_request_dro, work_version)
    SdrClient::Deposit::UpdateResource.run(metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection: connection,
                                           version_description: work_version.version_description.presence)
  end

  def perform_upload(blobs)
    SdrClient::Deposit::UploadFiles.upload(file_metadata: build_file_metadata(blobs),
                                           logger: Rails.logger,
                                           connection: connection)
  end

  def connection
    @connection ||= SdrClient::Connection.new(url: Settings.sdr_api.url)
  end

  def build_file_metadata(blobs)
    blobs.each_with_object({}) do |blob, obj|
      obj[filename(blob.key)] = SdrClient::Deposit::Files::DirectUploadRequest.new(checksum: blob.checksum,
                                                                                   byte_size: blob.byte_size,
                                                                                   content_type: blob.content_type,
                                                                                   filename: blob.filename.to_s)
    end
  end

  def filename(key)
    ActiveStorage::Blob.service.path_for(key)
  end

  def blob_map_for(work_version)
    return {} unless work_version

    work_version.attached_files.to_h do |af|
      [af.file.attachment.blob.filename.to_s, af.file.attachment.blob.checksum]
    end
  end

  def filenames_to_upload_for(work_version)
    this_version_blob_map = blob_map_for(work_version)
    prev_version_blob_map = blob_map_for(work_version.previous_version)

    # If it is only in this version's blob_map or if it is in both but the checksums are different then upload.
    this_version_blob_map.reject { |filename, checksum| checksum == prev_version_blob_map[filename] }.keys
  end

  def blobs_for(work_version, filenames)
    attached_files = work_version.attached_files.select do |af|
      filenames.include?(af.file.attachment.blob.filename.to_s)
    end
    attached_files.map { |af| af.file.attachment.blob }
  end

  def existing_file_identifier_map_for(druid)
    cocina_obj = find_cocina_object(druid)

    {}.tap do |map|
      cocina_obj.structural.contains.each do |file_set|
        file_set.structural.contains.each do |file|
          map[md5_for_cocina_file(file)] = file.externalIdentifier
        end
      end
    end
  end

  def find_cocina_object(druid)
    cocina_str = SdrClient::Find.run(druid, url: Settings.sdr_api.url, logger: Rails.logger)
    cocina_json = JSON.parse(cocina_str)
    Cocina::Models.build(cocina_json)
  end

  # This will take either a Cocina::Models::File or a hash of a Cocina::Models::File
  def md5_for_cocina_file(file)
    file.to_h[:hasMessageDigests].find { |md| md[:type] == 'md5' }[:digest]
  end
end
