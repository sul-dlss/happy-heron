# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  # rubocop:disable Metrics/AbcSize:
  def perform(work_version)
    Honeybadger.context({ work_version_id: work_version.id, druid: work_version.work.druid,
                          work_id: work_version.work.id, depositor_sunet: work_version.work.depositor.sunetid })

    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version: work_version)
    blobs = work_version.attached_files.map { |af| af.file.attachment.blob }

    login_result = login
    raise login_result.failure unless login_result.success?

    new_request_dro = SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: request_dro,
                                                                              upload_responses: upload_responses(blobs))

    case new_request_dro
    when Cocina::Models::RequestDRO
      create(new_request_dro, work_version)
    when Cocina::Models::DRO
      update(new_request_dro)
    end
  end
  # rubocop:enable Metrics/AbcSize:

  private

  def deposit(request_dro:, blobs:)
    login_result = login
    raise login_result.failure unless login_result.success?

    new_request_dro = SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: request_dro,
                                                                              upload_responses: upload_responses(blobs))

    create_or_update(new_request_dro)
  end

  def create(new_request_dro, work_version)
    SdrClient::Deposit::CreateResource.run(accession: true,
                                           assign_doi: work_version.work.assign_doi?,
                                           metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection: connection)
  end

  def update(new_request_dro)
    SdrClient::Deposit::UpdateResource.run(metadata: new_request_dro,
                                           logger: Rails.logger,
                                           connection: connection)
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
