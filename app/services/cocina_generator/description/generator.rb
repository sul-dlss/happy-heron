# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates a RequestDRO Description for a work
    class Generator
      def self.generate(work_version:)
        new(work_version:).generate
      end

      def initialize(work_version:)
        @work_version = work_version
      end

      # rubocop:disable Metrics/AbcSize
      def generate
        description_class.new({
          title:,
          contributor: ContributorsGenerator.generate(work_version:).presence,
          subject: keywords.presence,
          note: [abstract, citation].compact.presence,
          event: EventsGenerator.generate(work_version:).presence,
          relatedResource: related_resources.presence,
          form: TypesGenerator.generate(work_version:).presence,
          access:,
          purl: work_version.work.purl,
          adminMetadata: admin_metadata
        }.compact)
      end
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :work_version

      def description_class
        work_version.work.purl ? Cocina::Models::Description : Cocina::Models::RequestDescription
      end

      def title
        [
          Cocina::Models::Title.new(value: work_version.title)
        ]
      end

      def related_resources
        RelatedLinksGenerator.generate(object: work_version) + related_works
      end

      def keywords
        work_version.keywords.map do |keyword|
          props = {
            value: keyword.label, type: keyword.cocina_type.presence || 'topic'
          }
          if keyword.uri.present?
            props[:uri] = keyword.uri
            props[:source] = { code: 'fast', uri: 'http://id.worldcat.org/fast/' }
          end
          Cocina::Models::DescriptiveValue.new(props)
        end
      end

      def abstract
        return if work_version.abstract.blank?

        Cocina::Models::DescriptiveValue.new(
          value: work_version.abstract,
          type: 'abstract'
        )
      end

      def citation
        return if work_version.citation.blank?

        # :link: and :doi: are special placeholders in dor-services-app.
        # See https://github.com/sul-dlss/dor-services-app/pull/1566/files#diff-30396654f0ad00ad1daa7292fd8327759d7ff7f3b92f98f40a2e25b6839807e2R13
        exportable_citation = work_version.citation.gsub(WorkVersion::LINK_TEXT, ':link:').gsub(WorkVersion::DOI_TEXT,
                                                                                                ':doi:')

        Cocina::Models::DescriptiveValue.new(
          value: exportable_citation,
          type: 'preferred citation'
        )
      end

      def access
        args = {
          accessContact: access_contacts
        }.compact
        return if args.empty?

        Cocina::Models::DescriptiveAccessMetadata.new(args)
      end

      def access_contacts
        return if work_version.contact_emails.empty?

        work_version.contact_emails.map do |email|
          {
            value: email.email,
            type: 'email',
            displayLabel: 'Contact'
          }
        end
      end

      def related_works
        work_version.related_works.map do |rel_work|
          Cocina::Models::RelatedResource.new(
            note: [
              Cocina::Models::DescriptiveValue.new(type: 'preferred citation', value: rel_work.citation)
            ]
          )
        end
      end

      def admin_metadata
        Cocina::Models::DescriptiveAdminMetadata.new(
          event: [
            Cocina::Models::Event.new(type: 'creation',
                                      date: [DateGenerator.generate(date: admin_metadata_creation_date)])
          ],
          note: [
            Cocina::Models::DescriptiveValue.new(
              value: 'Metadata created by user via Stanford self-deposit application',
              type: 'record origin'
            )
          ]
        )
      end

      def admin_metadata_creation_date
        work_version.work.work_versions.first&.published_at || work_version.work.created_at
      end
    end
  end
end
