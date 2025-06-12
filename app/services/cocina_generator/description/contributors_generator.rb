# frozen_string_literal: true

module CocinaGenerator
  module Description
    # generates Cocina::Models::Contributors to be used by DescriptionGenerator
    # (ultimately in a Cocina::Models::RequestDRO)
    class ContributorsGenerator # rubocop:disable Metrics/ClassLength
      STANFORD_UNIVERSITY = 'Stanford University'
      DEGREE_GRANTING_INSTITUTION = 'Degree granting institution'

      def self.generate(...)
        new(...).generate
      end

      def initialize(work_version:, merge_stanford_and_organization: Settings.merge_stanford_and_organization)
        @work_version = work_version
        # When true, this uses the same stategy as H3 for Stanford (degree granting institution) and organizations.
        @merge_stanford_and_organization = merge_stanford_and_organization
      end

      # H2 Publisher becomes a Cocina::Models::Event, not a Contributor.  See events_from_publisher_contributors.

      def generate
        work_form_contributors.map.with_index do |work_form_contributor, index|
          # First entered contributor is always status: "primary" (except for Publisher)
          contributor(work_form_contributor, index.zero?)
        end
      end

      private

      attr_reader :work_version, :merge_stanford_and_organization

      def work_form_contributors
        contributors = (work_version.authors + work_version.contributors)
        return contributors unless merge_stanford_and_organization

        # If there are any departments, then remove Stanford degree granting institution contributors
        has_departments = contributors.any? { |c| c.role == 'Department' }
        contributors = contributors.reject { |c| stanford_degree_granting_institution?(c) } if has_departments
        contributors
      end

      def contributor(contributor, primary) # rubocop:disable Metrics/AbcSize
        Cocina::Models::Contributor.new({
          type: contributor_type(contributor),
          note: notes(contributor),
          identifier: identifiers(contributor)
        }.compact.tap do |contrib_hash|
          contrib_hash[:status] = 'primary' if primary
          if merge_stanford_and_organization && contributor.role == 'Department'
            contrib_hash[:name] = stanford_degree_granting_institution_name_values(contributor)
            contrib_hash[:role] = cocina_roles(DEGREE_GRANTING_INSTITUTION)
          else
            contrib_hash[:name] = name_descriptive_values(contributor)
            contrib_hash[:role] = cocina_roles(contributor.role)
          end
        end)
      end

      def name_descriptive_values(contributor)
        return [Cocina::Models::DescriptiveValue.new(value: full_name(contributor))] unless contributor.person?

        [Cocina::Models::DescriptiveValue.new(structuredValue: structured_name(contributor))]
      end

      def stanford_degree_granting_institution_name_values(contributor)
        [
          Cocina::Models::DescriptiveValue.new(structuredValue: [
                                                 {
                                                   value: STANFORD_UNIVERSITY,
                                                   identifier: stanford_identifiers
                                                 },
                                                 { value: contributor.full_name }
                                               ])
        ]
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

      def cocina_roles(role)
        [marcrelator_role(role) ||
          Cocina::Models::DescriptiveValue.new(value: role.downcase)]
      end

      def notes(contributor)
        notes = []
        if contributor.type == 'Contributor' && !Settings.no_citation_status_note
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
        if contributor.orcid
          source, value = Orcid.split(contributor.orcid)
          [Cocina::Models::DescriptiveValue.new(type: 'ORCID', value:, source: { uri: source })]
        elsif merge_stanford_and_organization && stanford_degree_granting_institution?(contributor)
          stanford_identifiers
        end
      end

      def stanford_identifiers
        [Cocina::Models::DescriptiveValue.new(uri: 'https://ror.org/00f54p054', type: 'ROR', source: { code: 'ror' })]
      end

      def stanford_degree_granting_institution?(contributor)
        contributor.full_name == STANFORD_UNIVERSITY && contributor.role == DEGREE_GRANTING_INSTITUTION
      end
    end
  end
end
