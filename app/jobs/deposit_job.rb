# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  # @raise [SdrClient::Find::Failed] if the (non-nil) druid cannot be found in SDR
  def perform(work_version)
    druid = work_version.work.druid # may be nil
    Honeybadger.context({ work_version_id: work_version.id, druid:,
                          work_id: work_version.work.id, depositor_sunet: work_version.work.depositor.sunetid })

    # NOTE: this login ensures `Repository.find` and various SdrClient::* calls below all have a valid token
    perform_login

    cocina_obj = Repository.find(druid) if druid
    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version:, cocina_obj:)

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
    # Only uploading new or changed files.
    # blobs_map is a map of relative filepath to blob
    blobs_map = staged_blobs(work_version)
    filepath_map = filepath_map_for(work_version)
    upload_responses = perform_upload(blobs_map, filepath_map)
    # Update with any new externalIdentifiers assigned by SDR API during upload.
    SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro:,
                                                            upload_responses:)
  end

  def create(new_request_dro, work_version)
    SdrClient::Deposit::CreateResource.run(accession: true,
                                           assign_doi: work_version.work.assign_doi?,
                                           metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection:)
  end

  def update(new_request_dro, work_version)
    SdrClient::Deposit::UpdateResource.run(metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection:,
                                           version_description: work_version.version_description.presence)
  end

  def perform_upload(blobs_map, filepath_map)
    SdrClient::Deposit::UploadFiles.upload(file_metadata: build_file_metadata(blobs_map),
                                           filepath_map:,
                                           logger: Rails.logger,
                                           connection:)
  end

  def connection
    @connection ||= SdrClient::Connection.new(url: Settings.sdr_api.url)
  end

  def build_file_metadata(blobs_map)
    blobs_map.transform_values do |blob|
      SdrClient::Deposit::Files::DirectUploadRequest.new(
        checksum: blob.checksum,
        byte_size: blob.byte_size,
        content_type: clean_content_type(blob.content_type),
        filename: blob.filename.to_s
      )
    end
  end

  def clean_content_type(content_type)
    # ActiveStorage is expecting "application/x-stata-dta" not "application/x-stata-dta;version=14"
    content_type&.split(';')&.first
  end

  def blob_filepath_for(blob)
    ActiveStorage::Blob.service.path_for(blob.key)
  end

  def staged_blobs(work_version)
    work_version.staged_files.to_h do |attached_file|
      [attached_file.path, attached_file.blob]
    end
  end

  def filepath_map_for(work_version)
    # attached_file.path contains the cocina filename (e.g. 'dir1/file1.txt')
    work_version.staged_files.to_h do |attached_file|
      [attached_file.path, blob_filepath_for(attached_file.file.blob)]
    end
  end
end
