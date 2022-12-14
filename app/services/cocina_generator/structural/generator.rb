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
      # 2) Rebuild filesets that have attached_files that are preserved
      # 3) Add new filesets that have attached_files in the local store.
      # 4) Sort the filesets by filename (each fileset has a single file in H2 design) ascending and case-insensitive
      def build_filesets
        (work_version.staged_files.map { |af| build_fileset(attached_file: af) } + find_preserved_filesets)
          .sort_by { |file_set_hash| file_set_hash.dig(:structural, :contains, 0).filename.downcase }
      end

      # @return [Hash] map of filename to matching fileset's cocina for preserved files.
      def find_preserved_filesets
        return [] unless cocina_obj

        # h2 only has one file per fileset
        cocina_obj
          .structural
          .contains
          .filter_map do |fileset|
          next unless (preserved_file = get_preserved_file(fileset.structural.contains.first.filename))

          build_fileset(attached_file: preserved_file, fileset:)
        end
      end

      def get_preserved_file(filename)
        work_version.preserved_files.find { |attached_file| attached_file.path == filename }
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def build_fileset(attached_file:, fileset: nil)
        # h2 only has one file per fileset
        cocina_file = fileset&.structural&.contains&.first
        resource_id = SecureRandom.uuid if cocina_file.blank?
        {
          type: Cocina::Models::FileSetType.file,
          version: work_version.version,
          label: attached_file.label,
          structural: {
            contains: [FileGenerator.generate(work_version:, attached_file:, resource_id:, cocina_file:)]
          }
        }.tap do |new_fileset|
          if fileset
            new_fileset[:externalIdentifier] = fileset&.externalIdentifier
          elsif work_version.work.druid
            # see https://github.com/sul-dlss/dor-services-app/blob/main/app/services/cocina/id_generator.rb
            new_fileset[:externalIdentifier] =
              "#{ID_NAMESPACE}/fileSet/#{work_version.work.druid.delete_prefix('druid:')}-#{resource_id}"
          end
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
