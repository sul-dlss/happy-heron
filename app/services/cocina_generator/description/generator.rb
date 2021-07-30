# typed: strict
# frozen_string_literal: true

module CocinaGenerator
  module Description
    # This generates a RequestDRO Description for a work
    class Generator # rubocop:disable Metrics/ClassLength
      extend T::Sig

      sig { params(work_version: WorkVersion).returns(Cocina::Models::Description) }
      def self.generate(work_version:)
        new(work_version: work_version).generate
      end

      sig { params(work_version: WorkVersion).void }
      def initialize(work_version:)
        @work_version = work_version
      end

      # rubocop:disable Metrics/AbcSize
      sig { returns(Cocina::Models::Description) }
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

      sig { returns(WorkVersion) }
      attr_reader :work_version

      sig { returns(T::Array[Cocina::Models::Title]) }
      def title
        [
          Cocina::Models::Title.new(value: work_version.title)
        ]
      end

      sig { returns(T::Array[Cocina::Models::Event]) }
      def generate_events
        pub_events = ContributorsGenerator.events_from_publisher_contributors(work_version: work_version,
                                                                              pub_date: published_date)
        return [T.must(created_date)] + pub_events if pub_events.present? && created_date
        return pub_events if pub_events.present? # and no created_date

        [created_date, published_date].compact # no pub_events
      end

      sig { returns(T::Array[Cocina::Models::RelatedResource]) }
      def related_resources
        RelatedLinksGenerator.generate(object: work_version) + related_works
      end

      sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
      def keywords
        work_version.keywords.map do |keyword|
          props = {
            value: T.must(keyword.label), type: 'topic'
          }
          if keyword.uri.present?
            props[:uri] = keyword.uri
            props[:source] = { code: 'fast', uri: 'http://id.worldcat.org/fast/' }
          end
          Cocina::Models::DescriptiveValue.new(props)
        end
      end

      sig { returns(T.nilable(Cocina::Models::DescriptiveValue)) }
      def abstract
        return if work_version.abstract.blank?

        Cocina::Models::DescriptiveValue.new(
          value: work_version.abstract,
          type: 'abstract'
        )
      end

      sig { returns(T.nilable(Cocina::Models::DescriptiveValue)) }
      def citation
        return if work_version.citation.blank?

        # :link: is a special placeholder in dor-services-app.
        # See https://github.com/sul-dlss/dor-services-app/pull/1566/files#diff-30396654f0ad00ad1daa7292fd8327759d7ff7f3b92f98f40a2e25b6839807e2R13
        exportable_citation = T.must(work_version.citation).gsub(WorkVersion::LINK_TEXT, ':link:')

        Cocina::Models::DescriptiveValue.new(
          value: exportable_citation,
          type: 'preferred citation'
        )
      end

      sig { returns(T.nilable(Cocina::Models::Event)) }
      def created_date
        event_for(work_version.created_edtf, 'creation')
      end

      sig { returns(T.nilable(Cocina::Models::Event)) }
      def published_date
        event_for(work_version.published_edtf, 'publication')
      end

      # rubocop:disable Metrics/MethodLength
      sig do
        params(date: T.nilable(T.any(Date, EDTF::Interval)), type: String).returns(T.nilable(Cocina::Models::Event))
      end
      def event_for(date, type)
        return unless date

        date_props = {
          encoding: { code: 'edtf' },
          type: type
        }

        if date.is_a?(EDTF::Interval)
          structured_values = []
          structured_values << date_props_for(date.from, type: 'start') if date.from
          structured_values << date_props_for(date.to, type: 'end') if date.to
          date_props[:structuredValue] = structured_values
          date_props[:qualifier] = 'approximate' if date.from&.uncertain? || date.to&.uncertain?
        else
          date_props.merge!(date_props_for(date))
        end

        Cocina::Models::Event.new(
          type: type,
          date: [date_props]
        )
      end
      # rubocop:enable Metrics/MethodLength

      sig { params(date: Date, type: T.nilable(String)).returns(T::Hash[T.untyped, T.untyped]) }
      def date_props_for(date, type: nil)
        {
          type: type,
          qualifier: date.uncertain? ? 'approximate' : nil,
          value: date.to_s
        }.compact
      end

      sig { returns(T.nilable(Cocina::Models::DescriptiveAccessMetadata)) }
      def access
        args = {
          accessContact: access_contacts,
          digitalRepository: repository
        }.compact
        return if args.empty?

        Cocina::Models::DescriptiveAccessMetadata.new(args)
      end

      sig { returns(T.nilable(T::Array[T::Hash[Symbol, String]])) }
      def repository
        return unless work_version.work.purl

        [{ value: 'Stanford Digital Repository' }]
      end

      sig { returns(T.nilable(T::Array[T::Hash[Symbol, String]])) }
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

      sig { returns(T::Array[Cocina::Models::RelatedResource]) }
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
      sig { returns(Cocina::Models::DescriptiveAdminMetadata) }
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
