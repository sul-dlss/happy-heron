# typed: strict
# frozen_string_literal: true

module CocinaGenerator
  module Description
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
        object.related_links.map { |rel_link| build_related_link(rel_link) }
      end

      private

      sig { returns(T.any(CollectionVersion, WorkVersion)) }
      attr_reader :object

      sig { params(rel_link: RelatedLink).returns(Cocina::Models::RelatedResource) }
      def build_related_link(rel_link)
        return purl_link(rel_link) if purl?(rel_link.url)

        resource_attrs = {
          access: Cocina::Models::DescriptiveAccessMetadata.new(
            url: [Cocina::Models::DescriptiveValue.new(value: rel_link.url)]
          )
        }
        resource_attrs[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
        Cocina::Models::RelatedResource.new(resource_attrs)
      end

      sig { params(rel_link: RelatedLink).returns(Cocina::Models::RelatedResource) }
      def purl_link(rel_link)
        resource_attrs = {
          purl: rel_link.url,
          access: Cocina::Models::DescriptiveAccessMetadata.new(
            digitalRepository: [Cocina::Models::DescriptiveValue.new(value: 'Stanford Digital Repository')]
          )
        }
        resource_attrs[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
        Cocina::Models::RelatedResource.new(resource_attrs)
      end

      sig { params(url: String).returns(T::Boolean) }
      def purl?(url)
        url.start_with?(Settings.purl_url)
      end
    end
  end
end
