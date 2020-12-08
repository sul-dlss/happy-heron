# typed: true
# frozen_string_literal: true

# This generates a description from RelatedLinks
class RelatedLinksGenerator
  extend T::Sig

  sig { params(object: T.any(CollectionVersion, WorkVersion)).returns(T::Array[Cocina::Models::RelatedResource]) }
  def self.generate(object:)
    new(object: object).generate
  end

  sig { params(object: T.any(CollectionVersion, WorkVersion)).void }
  def initialize(object:)
    @object = object
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def generate
    object.related_links.map do |rel_link|
      resource_attrs = {
        type: 'related to',
        access: Cocina::Models::DescriptiveAccessMetadata.new(
          url: [Cocina::Models::DescriptiveValue.new(value: rel_link.url)]
        )
      }
      resource_attrs[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
      Cocina::Models::RelatedResource.new(resource_attrs)
    end
  end

  private

  sig { returns(T.any(CollectionVersion, WorkVersion)) }
  attr_reader :object
end
