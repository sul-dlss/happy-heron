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
        object.related_links.map { |rel_link| build_related_link(rel_link) }
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

      # This normalizes the PURL link to https (as it is currently the canonincal PURL)
      def purl_link(rel_link)
        resource_attrs = {
          purl: rel_link.url.sub(/^https?/, 'https')
        }
        resource_attrs[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
        Cocina::Models::RelatedResource.new(resource_attrs)
      end

      def purl?(url)
        url.start_with?("https://#{purl_host}") || url.start_with?("http://#{purl_host}")
      end
    end
  end
end
