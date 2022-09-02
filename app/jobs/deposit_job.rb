# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

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
    if metadata_only?(work_version)
      update_dro_with_existing_file_identifiers(request_dro, work_version.work.druid)
    else
      blobs = work_version.attached_files.map { |af| af.file.attachment.blob }
      SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: request_dro,
                                                              upload_responses: upload_responses(blobs))
    end
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

  def upload_responses(blobs)
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

  def update_dro_with_existing_file_identifiers(request_dro, druid)
    request_dro.new(structural: request_dro.structural.new(contains: existing_structural_for(druid)))
  end

  def metadata_only?(work_version)
    previous_version = work_version.previous_version
    return false unless previous_version

    blob_map_for(work_version) == blob_map_for(previous_version)
  end

  def blob_map_for(work_version)
    work_version.attached_files.to_h do |af|
      [af.file.attachment.blob.filename.to_s, af.file.attachment.blob.checksum]
    end
  end

  def existing_structural_for(druid)
    cocina_str = SdrClient::Find.run(druid, url: Settings.sdr_api.url, logger: Rails.logger)
    cocina_json = JSON.parse(cocina_str)
    cocina = Cocina::Models.build(cocina_json)
    cocina.structural.contains
  end
end
