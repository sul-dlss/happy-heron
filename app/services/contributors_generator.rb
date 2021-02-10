# typed: true
# frozen_string_literal: true

# generates Cocina::Models::Contributors to be used by DescriptionGenerator (ultimately in a Cocina::Models::RequestDRO)
# rubocop:disable Metrics/ClassLength
class ContributorsGenerator
  extend T::Sig

  sig { params(work_version: WorkVersion).returns(T::Array[Cocina::Models::Contributor]) }
  def self.generate(work_version:)
    new(work_version: work_version).generate
  end

  sig { params(work_version: WorkVersion).returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def self.form_array_from_contributor_event(work_version:)
    new(work_version: work_version).form_array_from_contributor_event
  end

  sig do
    params(work_version: WorkVersion, pub_date: T.nilable(Cocina::Models::Event))
      .returns(T::Array[Cocina::Models::Event])
  end
  def self.events_from_publisher_contributors(work_version:, pub_date: nil)
    new(work_version: work_version).publication_event_values(pub_date)
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  # H2 Publisher becomes a Cocina::Models::Event, not a Contributor.  See events_from_publisher_contributors.
  sig { returns(T::Array[T.nilable(Cocina::Models::Contributor)]) }
  def generate
    count = 0
    work_version.contributors.reject { |c| c.role == 'Publisher' }
        .map do |work_form_contributor|
          count += 1
          # First entered contributor is always status: "primary" (except for Publisher)
          primary = count == 1
          contributor(work_form_contributor, primary)
        end
  end

  ROLES_FOR_FORM = %w[Event Conference].freeze

  # when there is an organization role of 'Event' or 'Conference', a form value must be added to descriptive metadata
  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def form_array_from_contributor_event
    return [] if work_version.contributors.select { |c| ROLES_FOR_FORM.include?(c.role) }.empty?

    [
      Cocina::Models::DescriptiveValue.new(
        value: 'Event',
        type: 'resource types',
        source: { value: 'DataCite resource types' }
      )
    ]
  end

  sig { params(pub_date: T.nilable(Cocina::Models::Event)).returns(T::Array[Cocina::Models::Event]) }
  def publication_event_values(pub_date)
    work_version.contributors.select { |c| c.role == 'Publisher' }.map do |publisher|
      event = {
        type: 'publication',
        contributor: [contributor(publisher, false)]
      }
      event[:date] = pub_date.date if pub_date

      Cocina::Models::Event.new(event)
    end
  end

  private

  sig { returns(WorkVersion) }
  attr_reader :work_version

  sig { params(contributor: Contributor, primary: T::Boolean).returns(Cocina::Models::Contributor) }
  def contributor(contributor, primary)
    contrib_hash = {
      name: name_descriptive_value(contributor),
      type: contributor_type(contributor),
      role: cocina_roles(contributor.role)
    }
    contrib_hash[:status] = 'primary' if primary
    Cocina::Models::Contributor.new(contrib_hash)
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
    'Conference' => nil, # see form_array_from_contributor_event
    'Degree granting institution' => 'Other',
    'Event' => nil, # see form_array_from_contributor_event
    'Funder' => nil,
    'Host institution' => 'HostingInstitution',
    'Issuing body' => 'Distributor',
    'Publisher' => nil, # see events_from_publisher_contributors
    'Research group' => 'ResearchGroup',
    'Sponsor' => 'Sponsor'
  }.freeze
end
# rubocop:enable Metrics/ClassLength
