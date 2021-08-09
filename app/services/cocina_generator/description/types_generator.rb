# frozen_string_literal: true

module CocinaGenerator
  module Description
    # Maps work types and subtypes to Cocina
    class TypesGenerator
      RESOURCE_TYPE_SOURCE_LABEL = 'Stanford self-deposit resource types'

      def self.generate(work_version:)
        new(work_version: work_version).generate
      end

      def initialize(work_version:)
        @work_version = work_version
      end

      def generate
        build_structured_values + build_genres + build_resource_types
      end

      private

      attr_reader :work_version

      def subtypes
        Array(work_version.subtype)
      end

      def work_type
        WorkType.find(work_version.work_type).label
      end

      def build_structured_values
        [
          Cocina::Models::DescriptiveValue.new(
            structuredValue: structured_type_and_subtypes,
            source: { value: RESOURCE_TYPE_SOURCE_LABEL },
            type: 'resource type'
          )
        ]
      end

      def structured_type_and_subtypes
        [Cocina::Models::DescriptiveValue.new(value: work_type, type: 'type')].concat(
          subtypes.map do |subtype|
            Cocina::Models::DescriptiveValue.new(value: subtype, type: 'subtype')
          end
        )
      end

      def build_genres
        return [] if work_type == 'Other'

        # add the top level genre mapping (i.e. top level work type with no subtype)
        type_genres = types_to_genres.dig(work_type, 'type') || []

        # NOTE: we should not add duplicate genres if the same one is coming from both the
        # top level mapping and then the sub-type. We will try and avoid duplicating
        # in the `types_to_genres.yml` mappings, but this `.uniq` ensures it.
        # see https://github.com/sul-dlss/happy-heron/issues/1254#issuecomment-790935330
        all_genres = (type_genres + subtype_genres).uniq
        all_genres.map { |genre| Cocina::Models::DescriptiveValue.new(genre) }
      end

      def subtype_genres
        # it's possible there is no genre found
        subtypes.flat_map { |subtype| types_to_genres.dig(work_type, 'subtypes', subtype) }.compact
      end

      def build_resource_types
        return [] if work_type == 'Other'

        # add the top level resource type mapping (i.e. top level work type with no subtype)
        resource_types = Array(types_to_resource_types.dig(work_type, 'type'))

        # uniq and compact the list of resource types, since multiple subtypes can map
        # to the same resource type but we only need them mapped once
        all_resource_type = (resource_types + subtype_resource_types).compact.uniq
        all_resource_type.map { |resource_type| Cocina::Models::DescriptiveValue.new(resource_type) }
      end

      def subtype_resource_types
        subtypes.flat_map do |subtype|
          Array(types_to_resource_types.dig(work_type, 'subtypes', subtype)).map do |resource_type|
            resource_type
          end
        end
      end

      def types_to_genres
        YAML.load_file(Rails.root.join('config/mappings/types_to_genres.yml'))
      end

      def types_to_resource_types
        YAML.load_file(Rails.root.join('config/mappings/types_to_resource_types.yml'))
      end
    end
  end
end
