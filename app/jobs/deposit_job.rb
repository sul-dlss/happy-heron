# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  def perform(work_version)
    deposit(request_dro: CocinaGenerator::DROGenerator.generate_model(work_version: work_version),
            blobs: work_version.attached_files.map { |af| af.file.attachment.blob })
  end

  private

  def deposit(request_dro:, blobs:)
    login_result = login
    raise login_result.failure unless login_result.success?

    new_request_dro = SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: request_dro,
                                                                              upload_responses: upload_responses(blobs))

    create_or_update(new_request_dro)
  end

  def create_or_update(new_request_dro)
    case new_request_dro
    when Cocina::Models::RequestDRO
      SdrClient::Deposit::CreateResource.run(accession: !arguments.first.reserving_purl?,
                                             metadata: new_request_dro,
                                             logger: Rails.logger,
                                             connection: connection)
    when Cocina::Models::DRO
      SdrClient::Deposit::UpdateResource.run(metadata: new_request_dro,
                                             logger: Rails.logger,
                                             connection: connection)
    end
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
end
