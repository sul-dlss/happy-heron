# typed: strict
# frozen_string_literal: true

# Maps work types and subtypes to Cocina
class TypesGenerator
  extend T::Sig

  RESOURCE_TYPE_SOURCE_LABEL = 'Stanford self-deposit resource types'

  sig { params(work_version: WorkVersion).returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def self.generate(work_version:)
    new(work_version: work_version).generate
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def generate
    build_structured_values + build_genres + build_resource_types
  end

  private

  sig { returns(WorkVersion) }
  attr_reader :work_version

  sig { returns(T::Array[T.nilable(String)]) }
  def subtypes
    Array(work_version.subtype)
  end

  sig { returns(String) }
  def work_type
    WorkType.find(work_version.work_type).label
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def build_structured_values
    [
      Cocina::Models::DescriptiveValue.new(
        structuredValue: structured_type_and_subtypes,
        source: { value: RESOURCE_TYPE_SOURCE_LABEL },
        type: 'resource type'
      )
    ]
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def structured_type_and_subtypes
    [Cocina::Models::DescriptiveValue.new(value: work_type, type: 'type')].concat(
      subtypes.map do |subtype|
        Cocina::Models::DescriptiveValue.new(value: subtype, type: 'subtype')
      end
    )
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def build_genres
    return [] if work_type == 'Other'

    # add the top level genre mapping (i.e. top level work type with no subtype)
    type_genres = types_to_genres.dig(work_type, 'type') || []

    all_genres = (type_genres + subtype_genres).uniq
    all_genres.map { |genre| Cocina::Models::DescriptiveValue.new(genre) }
  end

  sig { returns(T::Array[String]) }
  def subtype_genres
    # it's possible there is no genre found
    subtypes.flat_map { |subtype| types_to_genres.dig(work_type, 'subtypes', subtype) }.compact
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def build_resource_types
    return [] if work_type == 'Other'

    # add the top level resource type mapping (i.e. top level work type with no subtype)
    resource_types = Array(types_to_resource_types.dig(work_type, 'type'))

    # uniq and compact the list of resource types, since multiple subtypes can map
    # to the same resource type but we only need them mapped once
    all_resource_type = (resource_types + subtype_resource_types).compact.uniq
    all_resource_type.map { |resource_type| Cocina::Models::DescriptiveValue.new(resource_type) }
  end

  sig { returns(T::Array[String]) }
  def subtype_resource_types
    subtypes.flat_map do |subtype|
      Array(types_to_resource_types.dig(work_type, 'subtypes', subtype)).map do |resource_type|
        resource_type
      end
    end
  end

  sig { returns(T::Hash[String, T::Hash[String, T::Array[Cocina::Models::DescriptiveValue]]]) }
  def types_to_genres
    YAML.load_file(Rails.root.join('config/mappings/types_to_genres.yml'))
  end

  sig { returns(T::Hash[String, T::Hash[String, T::Array[Cocina::Models::DescriptiveValue]]]) }
  def types_to_resource_types
    YAML.load_file(Rails.root.join('config/mappings/types_to_resource_types.yml'))
  end
end
