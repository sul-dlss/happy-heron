# typed: false
# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  sig { params(work: Work).void }
  def perform(work)
    job_id = deposit(request_dro: RequestGenerator.generate_model(work: work),
                     blobs: work.attached_files.map { |af| af.file.attachment.blob })
    DepositStatusJob.perform_later(work: work, job_id: job_id)
  rescue StandardError => e
    Honeybadger.notify(e)
  end

  private

  sig { params(request_dro: Cocina::Models::RequestDRO, blobs: T::Array[ActiveStorage::Blob]).returns(Integer) }
  def deposit(request_dro:, blobs:)
    login_result = login

    raise login_result.failure unless login_result.success?

    new_request_dro = SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: request_dro,
                                                                              upload_responses: upload_responses(blobs))
    SdrClient::Deposit::UploadResource.run(accession: true,
                                           metadata: new_request_dro.to_json,
                                           logger: Rails.logger,
                                           connection: connection)
  end

  sig { params(blobs: T::Array[ActiveStorage::Blob]).returns(T::Array[SdrClient::Deposit::Files::DirectUploadRequest]) }
  def upload_responses(blobs)
    SdrClient::Deposit::UploadFiles.upload(file_metadata: build_file_metadata(blobs),
                                           logger: Rails.logger,
                                           connection: connection)
  end

  sig { returns(SdrClient::Connection) }
  def connection
    @connection ||= SdrClient::Connection.new(url: Settings.sdr_api.url)
  end

  sig do
    params(blobs: T::Array[ActiveStorage::Blob])
      .returns(T::Hash[String, SdrClient::Deposit::Files::DirectUploadRequest])
  end
  def build_file_metadata(blobs)
    blobs.each_with_object({}) do |blob, obj|
      obj[filename(blob.key)] = SdrClient::Deposit::Files::DirectUploadRequest.new(checksum: blob.checksum,
                                                                                   byte_size: blob.byte_size,
                                                                                   content_type: blob.content_type,
                                                                                   filename: blob.filename.to_s)
    end
  end

  sig { params(key: String).returns(String) }
  def filename(key)
    ActiveStorage::Blob.service.path_for(key)
  end
end
