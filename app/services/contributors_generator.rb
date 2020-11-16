# typed: true
# frozen_string_literal: true

# generates Cocina::Models::Contributors to be used by DescriptionGenerator (ultimately in a Cocina::Models::RequestDRO)
# rubocop:disable Metrics/ClassLength
class ContributorsGenerator
  extend T::Sig

  sig { params(work: Work).returns(T::Array[Cocina::Models::Contributor]) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def self.form_array_from_contributor_event(work:)
    new(work: work).form_array_from_contributor_event
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(T::Array[T.nilable(Cocina::Models::Contributor)]) }
  def generate
    work.contributors.map { |work_form_contributor| contributor(work_form_contributor) }
  end

  ROLES_FOR_FORM = %w[Event Conference].freeze

  # when there is an organization role of 'Event' or 'Conference', a form value must be added to descriptive metadata
  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def form_array_from_contributor_event
    return [] if work.contributors.select { |c| ROLES_FOR_FORM.include?(c.role) }.empty?

    [
      Cocina::Models::DescriptiveValue.new(
        value: 'Event',
        type: 'resource types',
        source: { value: 'DataCite resource types' }
      )
    ]
  end

  private

  sig { returns(Work) }
  attr_reader :work

  sig { params(contributor: Contributor).returns(T.nilable(Cocina::Models::Contributor)) }
  def contributor(contributor)
    # FIXME: TODO: mappings for status (primary) and/or order
    Cocina::Models::Contributor.new(
      name: name_descriptive_value(contributor),
      type: contributor_type(contributor),
      role: cocina_roles(contributor.role)
    )
  end

  sig { params(contributor: Contributor).returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def name_descriptive_value(contributor)
    return [Cocina::Models::DescriptiveValue.new(value: full_name(contributor))] unless contributor.person?

    [Cocina::Models::DescriptiveValue.new(value: full_name(contributor), type: 'inverted full name')]
  end

  sig { params(contributor: Contributor).returns(T.nilable(String)) }
  def full_name(contributor)
    return "#{contributor.last_name}, #{contributor.first_name}" if contributor.person?

    contributor.full_name
  end

  sig { params(contributor: Contributor).returns(String) }
  def contributor_type(contributor)
    return 'conference' if contributor.role == 'Conference'
    return 'event' if contributor.role == 'Event'

    contributor.contributor_type
  end

  sig { params(role: String).returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def cocina_roles(role)
    result = [h2_role_descriptive_value(role)]
    result << T.must(marcrelator_role(role)) if marcrelator_role(role)
    result << T.must(datacite_role(role)) if datacite_role(role)
    result
  end

  sig { params(role: String).returns(Cocina::Models::DescriptiveValue) }
  def h2_role_descriptive_value(role)
    Cocina::Models::DescriptiveValue.new(
      value: role,
      source: {
        value: 'Stanford self-deposit contributor types'
      }
    )
  end

  # rubocop:disable Metrics/MethodLength
  sig { params(role: String).returns(T.nilable(Cocina::Models::DescriptiveValue)) }
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
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  sig { params(role: String).returns(T.nilable(Cocina::Models::DescriptiveValue)) }
  def datacite_role(role)
    datacite_role = ROLE_TO_DATA_CITE_VALUE[role]
    return if datacite_role.blank?

    case datacite_role
    when String
      datacite_source = 'DataCite contributor types'
    when :creator
      datacite_role = datacite_role.to_s.capitalize
      datacite_source = 'DataCite properties'
    end

    Cocina::Models::DescriptiveValue.new(
      value: datacite_role,
      source: {
        value: datacite_source
      }
    )
  end
  # rubocop:enable Metrics/MethodLength

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
    'Primary thesis advisor' => 'ths',
    'Principal investigator' => 'rth',
    'Producer' => 'pro',
    'Researcher' => 'res',
    'Software developer' => 'prg',
    'Speaker' => 'spk',
    'Thesis advisor' => 'ths',
    # organization (when not already listed above)
    # 'Conference' => '', # not a marcrelator role
    'Degree granting institution' => 'dgg',
    # 'Event' => '', # not a marcrelator role
    'Funder' => 'fnd',
    'Host institution' => 'his',
    'Issuing body' => 'isb',
    'Publisher' => 'pbl',
    'Research group' => 'res',
    'Sponsor' => 'spn'
  }.freeze

  MARC_RELATOR_CODE_TO_VALUE = {
    'aut' => 'author',
    'cmp' => 'composer',
    'com' => 'compiler',
    'cph' => 'copyright holder',
    'cre' => 'creator',
    'ctb' => 'contributor',
    'dgg' => 'degree granting institution',
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
    'res' => 'researcher',
    'rth' => 'research team head',
    'spk' => 'speaker',
    'spn' => 'sponsor',
    'ths' => 'thesis advisor'
  }.freeze

  ROLE_TO_DATA_CITE_VALUE = {
    # person
    'Author' => :creator,
    'Composer' => :creator,
    'Contributing author' => :creator,
    'Copyright holder' => 'RightsHolder',
    'Creator' => :creator,
    'Data collector' => 'DataCollector',
    'Data contributor' => 'Other',
    'Editor' => 'Editor',
    'Event organizer' => 'Supervisor',
    'Interviewee' => 'Other',
    'Interviewer' => 'Other',
    'Performer' => 'Other',
    'Photographer' => :creator,
    'Primary thesis advisor' => 'Other',
    'Principal investigator' => 'ProjectLeader',
    'Producer' => 'Other',
    'Researcher' => 'Researcher',
    'Software developer' => :creator,
    'Speaker' => 'Other',
    'Thesis advisor' => 'Other',
    # organization (when not already listed above)
    'Conference' => nil, # see form_from_contributors
    'Degree granting institution' => 'Other',
    'Event' => nil, # see form_from_contributors
    'Funder' => nil,
    'Host institution' => 'HostingInstitution',
    'Issuing body' => 'Distributor',
    'Publisher' => nil,
    'Research group' => 'ResearchGroup',
    'Sponsor' => 'Sponsor'
  }.freeze
end
# rubocop:enable Metrics/ClassLength
