# typed: true
# frozen_string_literal: true

# This generates a DROStructural for a work
class StructuralGenerator
  extend T::Sig

  sig { params(work: Work).returns(T.any(Cocina::Models::DROStructural, Cocina::Models::RequestDROStructural)) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  attr_reader :work

  sig { returns(T.any(Cocina::Models::DROStructural, Cocina::Models::RequestDROStructural)) }
  def generate
    klass = work.druid ? Cocina::Models::DROStructural : Cocina::Models::RequestDROStructural
    klass.new(
      contains: build_filesets,
      isMemberOf: [work.collection.druid]
    )
  end

  def build_filesets
    work.attached_files.map.with_index(1) { |af, n| build_fileset(af, n) }
  end

  sig { params(attached_file: AttachedFile, offset: Integer).returns(Hash) }
  def build_fileset(attached_file, offset)
    {
      type: 'http://cocina.sul.stanford.edu/models/fileset.jsonld',
      version: work.version,
      label: attached_file.label,
      structural: {
        contains: [FileGenerator.generate(work: work, attached_file: attached_file)]
      }
    }.tap do |fileset|
      fileset[:externalIdentifier] = "#{work.druid.delete_prefix('druid:')}_#{offset}" if work.druid
    end
  end
end
