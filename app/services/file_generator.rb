# typed: true
# frozen_string_literal: true

# This generates a File for a work
class FileGenerator
  extend T::Sig

  sig do
    params(
      work_version: WorkVersion,
      attached_file: AttachedFile
    ).returns(T.nilable(T.any(Cocina::Models::File, Cocina::Models::RequestFile)))
  end
  def self.generate(work_version:, attached_file:)
    new(work_version: work_version, attached_file: attached_file).generate
  end

  sig { params(work_version: WorkVersion, attached_file: AttachedFile).void }
  def initialize(work_version:, attached_file:)
    @work_version = work_version
    @attached_file = attached_file
  end

  attr_reader :work_version, :attached_file

  sig { returns(T.nilable(T.any(Cocina::Models::File, Cocina::Models::RequestFile))) }
  def generate
    return nil unless blob

    if work_version.work.druid
      Cocina::Models::File.new(file_attributes)
    else
      Cocina::Models::RequestFile.new(request_file_attributes)
    end
  end

  def request_file_attributes
    {
      type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
      version: work_version.version,
      label: attached_file.label,
      filename: filename,
      access: access,
      administrative: administrative,
      hasMimeType: blob.content_type,
      hasMessageDigests: message_digests,
      size: blob.byte_size
    }
  end

  def file_attributes
    request_file_attributes.merge(externalIdentifier: external_identifier)
  end

  def filename
    blob.filename.to_s # File.basename(filename(blob.key))
  end

  def external_identifier
    "#{work_version.work.druid}/#{filename}" if work_version.work.druid
  end

  def administrative
    {
      publish: !hidden_file?,
      sdrPreserve: true,
      shelve: !hidden_file?
    }
  end

  def message_digests
    [
      { type: 'md5', digest: base64_to_hexdigest(blob.checksum) },
      { type: 'sha1', digest: Digest::SHA1.file(file_path(blob.key)).hexdigest }
    ]
  end

  def blob
    @blob ||= attached_file.file&.attachment&.blob
  end

  def hidden_file?
    attached_file.hide?
  end

  sig { returns(Hash) }
  def access
    if hidden_file?
      { access: 'dark', download: 'none' }
    else
      { access: 'world', download: 'world' }
    end
  end

  sig { params(key: String).returns(String) }
  def file_path(key)
    ActiveStorage::Blob.service.path_for(key)
  end

  def base64_to_hexdigest(base64)
    Base64.decode64(base64).unpack1('H*')
  end
end
