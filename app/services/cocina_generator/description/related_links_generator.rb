# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates a description from RelatedLinks
    class RelatedLinksGenerator
      def self.generate(object:)
        new(object:).generate
      end

      def initialize(object:)
        @object = object
        @purl_host = Settings.purl_url.sub(%r{^https?://}, '')
      end

      def generate
        if Settings.map_related_links_to_resources
          # map all links into related resources for compatibility with H3
          object.related_links.map { |rel_link| build_related_resources(rel_link) }
        else
          object.related_links.map { |rel_link| build_related_link(rel_link) }
        end
      end

      private

      attr_reader :object, :purl_host

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

      # For H3 compatibility where related links are mapped to related resources
      def build_related_resources(rel_link) # rubocop:disable Metrics/AbcSize
        return purl_link(rel_link) if purl?(rel_link.url)

        resource_attrs = if uri_type_for(rel_link.url).present?
                           {
                             identifier: [Cocina::Models::DescriptiveValue.new(uri: rel_link.url,
                                                                               type: uri_type_for(rel_link.url))]
                           }
                         else
                           {
                             access: Cocina::Models::DescriptiveAccessMetadata.new(
                               url: [Cocina::Models::DescriptiveValue.new(value: rel_link.url)]
                             )
                           }
                         end
        # only include title attributes for collections
        if object.is_a?(CollectionVersion)

          title = rel_link.link_title || rel_link.url
          resource_attrs[:title] = [{ value: title }]
        end

        Cocina::Models::RelatedResource.new(resource_attrs)
      end

      # This normalizes the PURL link to https (as it is currently the canonincal PURL)
      def purl_link(rel_link)
        resource_attrs = {
          purl: rel_link.url.sub(/^https?/, 'https')
        }
        # only include title attributes for H2 mappings
        if rel_link.link_title.present? && !Settings.map_related_links_to_resources
          resource_attrs[:title] = [{ value: rel_link.link_title }]
        end
        Cocina::Models::RelatedResource.new(resource_attrs)
      end

      def purl?(url)
        url.start_with?("https://#{purl_host}") || url.start_with?("http://#{purl_host}")
      end

      def uri_type_for(rel_link)
        return 'doi' if rel_link.include?('doi.org')
        return 'arxiv' if rel_link.include?('arxiv.org')

        'pmid' if rel_link.include?('pubmed.ncbi.nlm.nih.gov')
      end
    end
  end
end
