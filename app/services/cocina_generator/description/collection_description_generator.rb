# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates a Collection Description
    class CollectionDescriptionGenerator
      def self.generate(collection_version:)
        new(collection_version: collection_version).generate
      end

      def initialize(collection_version:)
        @collection_version = collection_version
      end

      def generate
        Cocina::Models::Description.new({
          title: title,
          relatedResource: related_resources.presence,
          access: access,
          purl: collection_version.collection.purl
        }.compact)
      end

      private

      attr_reader :collection_version

      def title
        [
          Cocina::Models::Title.new(value: collection_version.name)
        ]
      end

      def related_resources
        RelatedLinksGenerator.generate(object: collection_version)
      end

      def access
        args = {
          accessContact: access_contacts,
          digitalRepository: repository
        }.compact
        return if args.empty?

        Cocina::Models::DescriptiveAccessMetadata.new(args)
      end

      def repository
        return unless collection_version.collection.purl

        [{ value: 'Stanford Digital Repository' }]
      end

      def access_contacts
        return if collection_version.contact_emails.empty?

        collection_version.contact_emails.map do |email|
          {
            value: email.email,
            type: 'email',
            displayLabel: 'Contact'
          }
        end
      end
    end
  end
end
