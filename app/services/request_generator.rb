# typed: true
# frozen_string_literal: true

# This generates a RequestDRO for a work
class RequestGenerator
  extend T::Sig

  sig { params(work: Work).returns(Cocina::Models::RequestDRO) }
  def self.generate_model(work:)
    new(work: work).generate_model
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  def generate_model
    Cocina::Models::RequestDRO.new(generate)
  end

  sig { returns(Hash) }
  def generate
    {
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo
      },
      identification: {
        sourceId: "hydrus:#{work.id}" # TODO: what should this be?
      },
      structural: {
        contains: work.attached_files.map { |af| build_fileset(af) }
      },
      label: work.title,
      type: cocina_type,
      description: DescriptionGenerator.generate(work: work),
      version: 0
    }
  end

  private

  attr_reader :work

  sig { returns(String) }
  def cocina_type
    WorkType.find(work.work_type).cocina_type
  end

  sig { params(attached_file: AttachedFile).returns(Hash) }
  def build_fileset(attached_file)
    {
      type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
      version: 1,
      label: attached_file.label,
      structural: {
        contains: [build_file(attached_file)]
      }
    }
  end

  sig { params(attached_file: AttachedFile).returns(Hash) }
  def build_file(attached_file)
    blob = attached_file.file&.attachment&.blob
    return {} unless blob

    {
      type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
      version: 1,
      label: attached_file.label,
      filename: blob.filename.to_s, # File.basename(filename(blob.key)),
      access: {
        access: 'stanford' # TODO: This varies based on what the user selected
      },
      administrative: {
        sdrPreserve: true,
        shelve: !attached_file.hide?
      },
      hasMimeType: blob.content_type,
      hasMessageDigests: [
        { type: 'md5', digest: base64_to_hexdigest(blob.checksum) },
        { type: 'sha1', digest: Digest::SHA1.file(filename(blob.key)).hexdigest }
      ],
      size: blob.byte_size
    }
  end
  sig { params(key: String).returns(String) }
  def filename(key)
    ActiveStorage::Blob.service.path_for(key)
  end

  def base64_to_hexdigest(base64)
    Base64.decode64(base64).unpack1('H*')
  end
end
