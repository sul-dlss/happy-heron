# frozen_string_literal: true

module CocinaGenerator
  module Description
    # generates Cocina::Models::Contributors to be used by DescriptionGenerator
    # (ultimately in a Cocina::Models::RequestDRO)
    # rubocop:disable Metrics/ClassLength
    class ContributorsGenerator
      def self.generate(work_version:)
        new(work_version:).generate
      end

      def self.events_from_publisher_contributors(work_version:, pub_date: nil)
        new(work_version:).publication_event_values(pub_date)
      end

      def initialize(work_version:)
        @work_version = work_version
      end

      # H2 Publisher becomes a Cocina::Models::Event, not a Contributor.  See events_from_publisher_contributors.

      def generate
        count = 0
        (work_version.authors + work_version.contributors.reject { |c| c.role == 'Publisher' })
          .map do |work_form_contributor|
          count += 1
          # First entered contributor is always status: "primary" (except for Publisher)
          primary = count == 1
          contributor(work_form_contributor, primary)
        end
      end

      def publication_event_values(pub_date)
        (work_version.authors + work_version.contributors).select { |c| c.role == 'Publisher' }.map do |publisher|
          event = {
            type: 'publication',
            contributor: [publication_contributor(publisher)]
          }
          event[:date] = pub_date.date if pub_date

          Cocina::Models::Event.new(event)
        end
      end

      private

      attr_reader :work_version

      def contributor(contributor, primary)
        contrib_hash = {
          name: name_descriptive_value(contributor),
          type: contributor_type(contributor),
          role: cocina_roles(contributor),
          note: notes(contributor),
          identifier: identifiers(contributor)
        }.compact

        contrib_hash[:status] = 'primary' if primary
        Cocina::Models::Contributor.new(contrib_hash)
      end

      def publication_contributor(contributor)
        contrib_hash = {
          name: name_descriptive_value(contributor),
          role: [marcrelator_role(contributor.role)],
          type: contributor_type(contributor)
        }
        Cocina::Models::Contributor.new(contrib_hash)
      end

      def name_descriptive_value(contributor)
        return [Cocina::Models::DescriptiveValue.new(value: full_name(contributor))] unless contributor.person?

        [Cocina::Models::DescriptiveValue.new(structuredValue: structured_name(contributor))]
      end

      def structured_name(contributor)
        [
          Cocina::Models::DescriptiveValue.new(value: contributor.first_name, type: 'forename'),
          Cocina::Models::DescriptiveValue.new(value: contributor.last_name, type: 'surname')
        ]
      end

      def full_name(contributor)
        return "#{contributor.last_name}, #{contributor.first_name}" if contributor.person?

        contributor.full_name
      end

      def contributor_type(contributor)
        return 'conference' if contributor.role == 'Conference'
        return 'event' if contributor.role == 'Event'

        contributor.contributor_type
      end

      def cocina_roles(contributor)
        roles = []
        roles << (marcrelator_role(contributor.role) ||
          Cocina::Models::DescriptiveValue.new(value: contributor.role.downcase))
        roles
      end

      def notes(contributor)
        notes = []
        if contributor.type == 'Contributor'
          notes << Cocina::Models::DescriptiveValue.new(type: 'citation status',
                                                        value: 'false')
        end
        notes.concat(AffiliationsGenerator.generate(contributor:))
        notes.presence
      end

      def marcrelator_role(role)
        mr_code = ROLE_TO_MARC_RELATOR_CODE[role]
        mr_value = MARC_RELATOR_CODE_TO_VALUE[mr_code]
        return if !mr_code && !mr_value

        Cocina::Models::DescriptiveValue.new(
          value: mr_value,
          code: mr_code,
          uri: "http://id.loc.gov/vocabulary/relators/#{mr_code}",
          source: {
            code: 'marcrelator',
            uri: 'http://id.loc.gov/vocabulary/relators/'
          }
        )
      end

      ROLE_TO_MARC_RELATOR_CODE = {
        # person
        'Author' => 'aut',
        'Composer' => 'cmp',
        'Contributing author' => 'ctb',
        'Copyright holder' => 'cph',
        'Creator' => 'cre',
        'Data collector' => 'com',
        'Data contributor' => 'dtc',
        'Editor' => 'edt',
        'Event organizer' => 'orm',
        'Interviewee' => 'ive',
        'Interviewer' => 'ivr',
        'Performer' => 'prf',
        'Photographer' => 'pht',
        'Primary thesis advisor' => 'dgs',
        'Principal investigator' => 'rth',
        'Producer' => 'pro',
        'Researcher' => 'res',
        'Software developer' => 'prg',
        'Speaker' => 'spk',
        'Thesis advisor' => 'dgc',
        # organization (when not already listed above)
        # 'Conference' => '', # not a marcrelator role
        'Degree granting institution' => 'dgg',
        'Distributor' => 'prv',
        # 'Event' => '', # not a marcrelator role
        'Funder' => 'fnd',
        'Host institution' => 'his',
        'Issuing body' => 'isb',
        'Publisher' => 'pbl',
        'Research group' => 'res',
        'Sponsor' => 'spn'
      }.freeze
      private_constant :ROLE_TO_MARC_RELATOR_CODE

      MARC_RELATOR_CODE_TO_VALUE = {
        'aut' => 'author',
        'cmp' => 'composer',
        'com' => 'compiler',
        'cph' => 'copyright holder',
        'cre' => 'creator',
        'ctb' => 'contributor',
        'dgg' => 'degree granting institution',
        'dgc' => 'degree committee member',
        'dgs' => 'degree supervisor',
        'dtc' => 'data contributor',
        'edt' => 'editor',
        'fnd' => 'funder',
        'his' => 'host institution',
        'isb' => 'issuing body',
        'ive' => 'interviewee',
        'ivr' => 'interviewer',
        'orm' => 'organizer',
        'pbl' => 'publisher',
        'pht' => 'photographer',
        'prf' => 'performer',
        'prg' => 'programmer',
        'pro' => 'producer',
        'prv' => 'provider',
        'res' => 'researcher',
        'rth' => 'research team head',
        'spk' => 'speaker',
        'spn' => 'sponsor'
      }.freeze
      private_constant :MARC_RELATOR_CODE_TO_VALUE

      def identifiers(contributor)
        return unless contributor.orcid

        source, value = Orcid.split(contributor.orcid)

        [
          Cocina::Models::DescriptiveValue.new(type: 'ORCID', value:, source: { uri: source })
        ]
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
