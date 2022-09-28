# frozen_string_literal: true

module CocinaGenerator
  module Structural
    # This generates a DROStructural for a work
    class Generator
      def self.generate(work_version:, cocina_obj:)
        new(work_version:, cocina_obj:).generate
      end

      def initialize(work_version:, cocina_obj:)
        @work_version = work_version
        @cocina_obj = cocina_obj
      end

      attr_reader :work_version, :cocina_obj

      def generate
        klass = work_version.work.druid ? Cocina::Models::DROStructural : Cocina::Models::RequestDROStructural
        klass.new(
          contains: build_filesets,
          isMemberOf: [work_version.work.collection.druid]
        )
      end

      # 1) Start with the existing filesets from SDR
      # 1) Only keep the filesets that have attached_files that are preserved
      # 2) Add new filesets that have attached_files in the local store.
      def build_filesets
        filesets = find_preserved_filesets
        filesets + work_version.staged_files.map.with_index(filesets.size + 1) { |af, n| build_fileset(af, n) }
      end

      # @return [Array<Cocina::FileSet>] the list of items where all files are already preserved.
      def find_preserved_filesets
        return [] unless cocina_obj

        cocina_obj.structural.contains.select do |fileset|
          existing_file_names = Set.new(fileset.structural.contains.map(&:filename))
          preserved_file_names = Set.new(work_version.preserved_files.map(&:filename).map(&:to_s))
          preserved_file_names.superset?(existing_file_names)
        end
      end

      def build_fileset(attached_file, offset)
        {
          type: Cocina::Models::FileSetType.file,
          version: work_version.version,
          label: attached_file.label,
          structural: {
            contains: [FileGenerator.generate(work_version:, attached_file:)]
          }
        }.tap do |fileset|
          if work_version.work.druid
            fileset[:externalIdentifier] =
              "#{work_version.work.druid.delete_prefix('druid:')}_#{offset}"
          end
        end
      end
    end
  end
end
