# typed: false
# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  sig { params(work_version: WorkVersion).void }
  def perform(work_version)
    login_result = login
    raise login_result.failure unless login_result.success?

    updated_cocina_model = upload_files(work_version)

    case updated_cocina_model
    when Cocina::Models::RequestDRO
      create(updated_cocina_model, accession: !work_version.reserving_purl?)
    when Cocina::Models::DRO
      update(updated_cocina_model)
    end
  end

  private

  sig { params(work_version: WorkVersion).returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def upload_files(work_version)
    cocina_model = RequestGenerator.generate_model(work_version: work_version)

    upload_responses = upload_responses(collect_blobs(work_version))
    SdrClient::Deposit::UpdateDroWithFileIdentifiers.update(request_dro: cocina_model,
                                                            upload_responses: upload_responses)
  end

  sig do
    params(work_version: WorkVersion).returns(T::Array[ActiveStorage::Blob])
  end
  def collect_blobs(work_version)
    work_version.attached_files.map { |af| af.file.attachment.blob }
  end

  sig do
    params(request_dro: Cocina::Models::RequestDRO,
           accession: T::Boolean).returns(Integer)
  end
  # Accession is set if true if this is a deposit and false if this is registering a DRUID
  def create(request_dro, accession:)
    SdrClient::Deposit::CreateResource.run(accession: accession,
                                           metadata: request_dro,
                                           logger: Rails.logger,
                                           connection: connection)
  end

  sig { params(request_dro: Cocina::Models::DRO).returns(Integer) }
  def update(request_dro)
    SdrClient::Deposit::UpdateResource.run(metadata: request_dro,
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
