# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates a RequestDRO Description for a work
    class Generator # rubocop:disable Metrics/ClassLength
      def self.generate(work_version:)
        new(work_version: work_version).generate
      end

      def initialize(work_version:)
        @work_version = work_version
      end

      # rubocop:disable Metrics/AbcSize

      def generate
        Cocina::Models::Description.new({
          title: title,
          contributor: ContributorsGenerator.generate(work_version: work_version).presence,
          subject: keywords.presence,
          note: [abstract, citation].compact.presence,
          event: generate_events.presence,
          relatedResource: related_resources.presence,
          form: TypesGenerator.generate(work_version: work_version).presence,
          access: access,
          purl: work_version.work.purl,
          adminMetadata: admin_metadata
        }.compact)
      end
      # rubocop:enable Metrics/AbcSize

      private

      attr_reader :work_version

      def title
        [
          Cocina::Models::Title.new(value: work_version.title)
        ]
      end

      def generate_events
        pub_events = ContributorsGenerator.events_from_publisher_contributors(work_version: work_version,
                                                                              pub_date: published_date)
        return [created_date] + pub_events if pub_events.present? && created_date
        return pub_events if pub_events.present? # and no created_date

        [created_date, published_date].compact # no pub_events
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

        # :link: is a special placeholder in dor-services-app.
        # See https://github.com/sul-dlss/dor-services-app/pull/1566/files#diff-30396654f0ad00ad1daa7292fd8327759d7ff7f3b92f98f40a2e25b6839807e2R13
        exportable_citation = work_version.citation.gsub(WorkVersion::LINK_TEXT, ':link:')

        Cocina::Models::DescriptiveValue.new(
          value: exportable_citation,
          type: 'preferred citation'
        )
      end

      def created_date
        event_for(work_version.created_edtf, 'creation')
      end

      def published_date
        event_for(work_version.published_edtf, 'publication')
      end

      def event_for(date, type)
        return unless date

        date_props = {
          encoding: { code: 'edtf' },
          type: type
        }.merge(date.is_a?(EDTF::Interval) ? interval_props_for(date) : date_props_for(date))

        Cocina::Models::Event.new(
          type: type,
          date: [date_props]
        )
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity

      def interval_props_for(date)
        structured_values = []
        structured_values << date_props_for(date.from, type: 'start') if date.from
        structured_values << date_props_for(date.to, type: 'end') if date.to
        result_props = {
          structuredValue: structured_values
        }

        if date.from&.uncertain? || date.to&.uncertain?
          result_props[:qualifier] = 'approximate'
          result_props[:structuredValue].each { |struct_date_val| struct_date_val.delete(:qualifier) }
        end

        result_props.compact
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity

      def date_props_for(date, type: nil)
        {
          type: type,
          qualifier: date.uncertain? ? 'approximate' : nil,
          value: date.to_s
        }.compact
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
        return unless work_version.work.purl

        [{ value: 'Stanford Digital Repository' }]
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

      # rubocop:disable Metrics/MethodLength

      def admin_metadata
        Cocina::Models::DescriptiveAdminMetadata.new(
          event: [
            Cocina::Models::Event.new(type: 'creation',
                                      date: [
                                        {
                                          value: work_version.work.created_at.strftime('%Y-%m-%d'),
                                          encoding: { code: 'w3cdtf' }
                                        }
                                      ])
          ],
          note: [
            Cocina::Models::DescriptiveValue.new(
              value: 'Metadata created by user via Stanford self-deposit application',
              type: 'record origin'
            )
          ]
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
