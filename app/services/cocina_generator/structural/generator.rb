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
      # 2) Only keep the filesets that have attached_files that are preserved
      # 3) Add new filesets that have attached_files in the local store.
      def build_filesets
        filesets = find_preserved_filesets
        # new step to check for label differences between old cocina and preserved_files
        unchanged_filesets, updated_filesets = check_labels(filesets) # make broader (e.g. find_differences)
        unchanged_filesets + updated_filesets.map.with_index(unchanged_filesets.size + 1) { |af, n| rebuild_fileset(af, n) } +
          work_version.staged_files.map.with_index(filesets.size + 1) { |af, n| build_fileset(af, n) }
      end

      # @return [Array<Cocina::FileSet>] the list of items where all files are already preserved.
      def find_preserved_filesets
        return [] unless cocina_obj

        # need to find preserved_filesets and update their label with the work version's description for the file if it's different.
        # h2 will only have one file per fileset
        cocina_obj.structural.contains.select do |fileset|
          existing_file_name = fileset.structural.contains.first.filename
          preserved_file_names = work_version.preserved_files.map(&:filename).map(&:to_s)
          preserved_file_names.include?(existing_file_name)
        end
      end

      def check_labels(preserved_filesets)
        # The label is the only thing that might change.
        # @return [Array<Cocina::FileSet>] list of unchanged files' cocina, and an array of changed preserved_files to get rebuilt.
        files = preserved_filesets.partition do |fileset|
          # find the preserved file with a filename that matches the cocina fileset
          preserved_file = work_version.preserved_files.select { |file| file.filename.to_s == fileset.structural.contains.first.filename }
          fileset.structural.contains.first.label == preserved_file.first.label.to_s
        end

        unchanged_files_cocina = files[0]
        updated_files_cocina = files[1]
        # get the filenames so we can use them to look up the matching preserved file
        changed_filenames = updated_files_cocina.map { |fileset| fileset.structural.contains.first.filename }
        # get the preserved_files that are changed
        need_to_be_rebuilt = work_version.preserved_files.select { |file| changed_filenames.include? file.filename.to_s }

        return unchanged_files_cocina, need_to_be_rebuilt
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

      def rebuild_fileset(attached_file, offset)
        # needs sdr-api's assigned externalIdentifier
        file_cocina = cocina_obj.structural.contains.first.structural.contains.find { |f| f.filename == attached_file.filename.to_s }
        external_identifier = file_cocina.externalIdentifier
        {
          type: Cocina::Models::FileSetType.file,
          version: work_version.version,
          label: attached_file.label,
          structural: {
            contains: [FileGenerator.generate(work_version:, attached_file:, external_identifier:)]
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
