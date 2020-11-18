# typed: true
# frozen_string_literal: true

# This generates a RequestDRO for a work
class RequestGenerator
  extend T::Sig

  sig { params(work: Work).returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def self.generate_model(work:)
    new(work: work).generate_model
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(T.any(Cocina::Models::RequestDRO, Cocina::Models::DRO)) }
  def generate_model
    if work.druid
      Cocina::Models::DRO.new(model_attributes.merge(externalIdentifier: work.druid), false, false)
    else
      Cocina::Models::RequestDRO.new(model_attributes, false, false)
    end
  end

  private

  attr_reader :work

  sig { returns(Hash) }
  def model_attributes
    {
      access: { access: 'stanford', download: 'stanford' },
      administrative: {
        hasAdminPolicy: Settings.h2.hydrus_apo
      },
      identification: {
        sourceId: "hydrus:#{work.id}" # TODO: what should this be?
      },
      structural: structural,
      label: work.title,
      type: cocina_type,
      description: DescriptionGenerator.generate(work: work),
      version: work.version
    }
  end

  sig { returns(String) }
  def cocina_type
    WorkType.find(work.work_type).cocina_type
  end

  sig { returns(Hash) }
  # TODO: This varies based on what the user selected
  def access
    {
      access: 'stanford',
      download: 'stanford'
    }
  end

  sig { returns(Hash) }
  def structural
    {
      contains: work.attached_files.map.with_index(1) { |af, n| build_fileset(af, n) }
    }
  end

  sig { params(attached_file: AttachedFile, offset: Integer).returns(Hash) }
  def build_fileset(attached_file, offset)
    {
      type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
      version: work.version,
      label: attached_file.label,
      structural: {
        contains: [build_file(attached_file)]
      }
    }.tap do |fileset|
      fileset[:externalIdentifier] = "#{work.druid.delete_prefix('druid:')}_#{offset}" if work.druid
    end
  end

  sig { params(attached_file: AttachedFile).returns(Hash) }
  # rubocop:disable Metrics/AbcSize
  def build_file(attached_file)
    blob = attached_file.file&.attachment&.blob
    return {} unless blob

    {
      type: 'http://cocina.sul.stanford.edu/models/file.jsonld',
      version: work.version,
      label: attached_file.label,
      filename: blob.filename.to_s, # File.basename(filename(blob.key)),
      access: access,
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
    }.tap do |file|
      file[:externalIdentifier] = "#{work.druid}/#{blob.filename}" if work.druid
    end
  end
  # rubocop:enable Metrics/AbcSize

  sig { params(key: String).returns(String) }
  def filename(key)
    ActiveStorage::Blob.service.path_for(key)
  end

  def base64_to_hexdigest(base64)
    Base64.decode64(base64).unpack1('H*')
  end
end
