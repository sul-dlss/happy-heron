# typed: true
# frozen_string_literal: true

# This generates a DROStructural for a work
class StructuralGenerator
  extend T::Sig

  sig do
    params(work_version: WorkVersion).returns(T.any(Cocina::Models::DROStructural,
                                                    Cocina::Models::RequestDROStructural))
  end
  def self.generate(work_version:)
    new(work_version: work_version).generate
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  attr_reader :work_version

  sig { returns(T.any(Cocina::Models::DROStructural, Cocina::Models::RequestDROStructural)) }
  def generate
    klass = work_version.work.druid ? Cocina::Models::DROStructural : Cocina::Models::RequestDROStructural
    klass.new(
      contains: build_filesets,
      isMemberOf: [work_version.work.collection.druid]
    )
  end

  def build_filesets
    work_version.attached_files.map.with_index(1) { |af, n| build_fileset(af, n) }
  end

  sig { params(attached_file: AttachedFile, offset: Integer).returns(Hash) }
  def build_fileset(attached_file, offset)
    {
      type: 'http://cocina.sul.stanford.edu/models/resources/file.jsonld',
      version: work_version.version,
      label: attached_file.label,
      structural: {
        contains: [FileGenerator.generate(work_version: work_version, attached_file: attached_file)]
      }
    }.tap do |fileset|
      if work_version.work.druid
        fileset[:externalIdentifier] =
          "#{work_version.work.druid.delete_prefix('druid:')}_#{offset}"
      end
    end
  end
end
