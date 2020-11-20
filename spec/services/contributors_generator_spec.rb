# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributorsGenerator do
  subject(:cocina_model) { described_class.generate(work: work) }

  let(:stanford_self_deposit_source) do
    {
      value: 'Stanford self-deposit contributor types'
    }
  end
  let(:marc_relator_source) do
    {
      code: 'marcrelator',
      uri: 'http://id.loc.gov/vocabulary/relators/'
    }
  end
  let(:datacite_creator_role) do
    Cocina::Models::DescriptiveValue.new(
      value: 'Creator',
      source: { value: 'DataCite properties' }
    )
  end
  let(:contributing_author_roles) do
    [
      {
        value: 'Contributing author',
        source: stanford_self_deposit_source
      },
      Cocina::Models::DescriptiveValue.new(
        value: 'contributor',
        code: 'ctb',
        uri: 'http://id.loc.gov/vocabulary/relators/ctb',
        source: marc_relator_source
      ),
      datacite_creator_role
    ]
  end
  let(:author_roles) do
    [
      {
        value: 'Author',
        source: stanford_self_deposit_source
      },
      {
        value: 'author',
        code: 'aut',
        uri: 'http://id.loc.gov/vocabulary/relators/aut',
        source: marc_relator_source
      },
      datacite_creator_role
    ]
  end
  let(:sponsor_roles) do
    [
      {
        value: 'Sponsor',
        source: stanford_self_deposit_source
      },
      Cocina::Models::DescriptiveValue.new(
        value: 'sponsor',
        code: 'spn',
        uri: 'http://id.loc.gov/vocabulary/relators/spn',
        source: marc_relator_source
      ),
      Cocina::Models::DescriptiveValue.new(
        value: 'Sponsor',
        source: { value: 'DataCite contributor types' }
      )
    ]
  end
  let(:publisher_roles) do
    [
      {
        value: 'Publisher',
        source: stanford_self_deposit_source
      },
      Cocina::Models::DescriptiveValue.new(
        value: 'publisher',
        code: 'pbl',
        uri: 'http://id.loc.gov/vocabulary/relators/pbl',
        source: marc_relator_source
      )
    ]
  end
  let(:event_form) do
    Cocina::Models::DescriptiveValue.new(
      value: 'Event',
      type: 'resource types',
      source: { value: 'DataCite resource types' }
    )
  end

  describe '.events_from_publisher_contributors' do
    context 'with no pub_date' do
      context 'with no publisher' do
        let(:contributor) { build(:contributor) }
        let(:work) { build(:work, contributors: [contributor]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work: work) }

        it 'returns empty Array' do
          expect(cocina_model).to eq []
        end
      end

      context 'with multiple publishers' do
        let(:org_contrib1) { build(:contributor, :with_org_contributor, role: 'Publisher') }
        let(:org_contrib2) { build(:contributor, :with_org_contributor, role: 'Publisher') }
        let(:work) { build(:work, contributors: [org_contrib1, org_contrib2]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work: work) }

        it 'returns Array of populated cocina model events, one for each publisher' do
          expect(cocina_model).to eq(
            [
              Cocina::Models::Event.new(
                type: 'publication',
                contributor: [
                  {
                    name: [{ value: org_contrib1.full_name }],
                    type: 'organization',
                    role: publisher_roles
                  }
                ]
              ),
              Cocina::Models::Event.new(
                type: 'publication',
                contributor: [
                  {
                    name: [{ value: org_contrib2.full_name }],
                    type: 'organization',
                    role: publisher_roles
                  }
                ]
              )
            ]
          )
        end
      end
    end

    context 'with a pub date' do
      let(:pub_date_value) do
        [
          {
            value: work.published_edtf,
            encoding: { code: 'edtf' }
          }
        ]
      end
      let(:pub_date) do
        Cocina::Models::Event.new(
          type: 'publication',
          date: pub_date_value
        )
      end

      context 'with no publisher' do
        let(:contributor) { build(:contributor) }
        let(:work) { build(:work, contributors: [contributor]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work: work, pub_date: pub_date) }

        it 'returns empty Array' do
          expect(cocina_model).to eq []
        end
      end

      context 'with multiple publishers' do
        let(:org_contrib1) { build(:contributor, :with_org_contributor, role: 'Publisher') }
        let(:org_contrib2) { build(:contributor, :with_org_contributor, role: 'Publisher') }
        let(:work) { build(:work, contributors: [org_contrib1, org_contrib2]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work: work, pub_date: pub_date) }

        it 'returns Array of populated cocina model events, one for each publisher' do
          expect(cocina_model).to eq(
            [
              Cocina::Models::Event.new(
                type: 'publication',
                date: pub_date_value,
                contributor: [
                  {
                    name: [{ value: org_contrib1.full_name }],
                    type: 'organization',
                    role: publisher_roles
                  }
                ]
              ),
              Cocina::Models::Event.new(
                type: 'publication',
                date: pub_date_value,
                contributor: [
                  {
                    name: [{ value: org_contrib2.full_name }],
                    type: 'organization',
                    role: publisher_roles
                  }
                ]
              )
            ]
          )
        end
      end
    end
  end

  context 'without marcrelator mapping' do
    let(:contributor) { build(:contributor, :with_org_contributor, role: 'Conference') }
    let(:work) { build(:work, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor without marc relator role' do
      expect(cocina_model).to eq(
        [
          Cocina::Models::Contributor.new(
            name: [{ value: contributor.full_name }],
            type: 'conference',
            status: 'primary',
            role: [
              {
                value: 'Conference',
                source: stanford_self_deposit_source
              }
            ]
          )
        ]
      )
    end
  end

  context 'with DataCite creator mapping for role' do
    let(:contributor) { build(:contributor) }
    let(:work) { build(:work, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor with DataCite role' do
      expect(cocina_model).to eq(
        [
          Cocina::Models::Contributor.new(
            name: [
              {
                value: "#{contributor.last_name}, #{contributor.first_name}",
                type: 'inverted full name'
              }
            ],
            type: 'person',
            status: 'primary',
            role: contributing_author_roles
          )
        ]
      )
    end
  end

  # from https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  describe 'h2 mapping specification examples' do
    context 'with person with single role' do
      let(:contributor) { build(:contributor, role: 'Data collector') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor with DataCite role' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor.last_name}, #{contributor.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              status: 'primary',
              role: [
                {
                  value: 'Data collector',
                  source: stanford_self_deposit_source
                },
                Cocina::Models::DescriptiveValue.new(
                  value: 'compiler',
                  code: 'com',
                  uri: 'http://id.loc.gov/vocabulary/relators/com',
                  source: marc_relator_source
                ),
                Cocina::Models::DescriptiveValue.new(
                  value: 'DataCollector',
                  source: {
                    value: 'DataCite contributor types'
                  }
                )
              ]
            )
          ]
        )
      end

      it 'ContributorsGenerator.form_array_from_contributor_event returns []' do
        expect(described_class.form_array_from_contributor_event(work: work)).to eq []
      end
    end

    context 'with person with multiple roles, one maps to DataCite creator property' do
      # NOTE: deduping of names to get multiple roles has been officially postponed by Amy and Arcadia
      xit 'TODO: https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt#L50'
    end

    context 'with organization with single role' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Host institution') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor without marc relator role' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'organization',
              status: 'primary',
              role: [
                {
                  value: 'Host institution',
                  source: stanford_self_deposit_source
                },
                Cocina::Models::DescriptiveValue.new(
                  value: 'host institution',
                  code: 'his',
                  uri: 'http://id.loc.gov/vocabulary/relators/his',
                  source: marc_relator_source
                ),
                Cocina::Models::DescriptiveValue.new(
                  value: 'HostingInstitution',
                  source: {
                    value: 'DataCite contributor types'
                  }
                )
              ]
            )
          ]
        )
      end
    end

    context 'with organization with multiple roles' do
      # NOTE: deduping of names to get multiple roles has been officially postponed by Amy and Arcadia
      xit 'TODO: https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt#L150'
    end

    context 'with conference as contributor' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Conference') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'conference',
              status: 'primary',
              role: [
                {
                  value: 'Conference',
                  source: stanford_self_deposit_source
                }
              ]
            )
          ]
        )
      end

      it 'ContributorsGenerator.form_array_from_contributor_event returns populated form attribute' do
        form = described_class.form_array_from_contributor_event(work: work)
        expect(form).to eq [event_form]
      end
    end

    context 'with event as contributor' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Event') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor with DataCite role' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'event',
              status: 'primary',
              role: [
                {
                  value: 'Event',
                  source: stanford_self_deposit_source
                }
              ]
            )
          ]
        )
      end

      it 'ContributorsGenerator.form_array_from_contributor_event returns populated form attribute' do
        form = described_class.form_array_from_contributor_event(work: work)
        expect(form).to eq [event_form]
      end
    end

    context 'with multiple person contributors' do
      let(:contributor1) { build(:contributor, role: 'Author') }
      let(:contributor2) { build(:contributor, role: 'Author') }
      let(:work) { build(:work, contributors: [contributor1, contributor2]) }

      # TODO: implement order

      it 'creates array of Cocina::Models::Contributor, one for each person contributor' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor1.last_name}, #{contributor1.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              status: 'primary',
              # order: 1,
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor2.last_name}, #{contributor2.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              # order: 2,
              role: author_roles
            )
          ]
        )
      end
    end

    context 'with multiple contributors - person and organization' do
      let(:contributor1) { build(:contributor, role: 'Author') }
      let(:contributor2) { build(:contributor, :with_org_contributor, role: 'Sponsor') }
      let(:work) { build(:work, contributors: [contributor1, contributor2]) }

      it 'creates array of Cocina::Models::Contributors' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor1.last_name}, #{contributor1.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              status: 'primary',
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [{ value: contributor2.full_name }],
              type: 'organization',
              role: sponsor_roles
            )
          ]
        )
      end
    end

    context 'with multipe person contributors and organization as author' do
      let(:contributor1) { build(:contributor, role: 'Author') }
      let(:contributor2) { build(:contributor, :with_org_contributor, role: 'Author') }
      let(:contributor3) { build(:contributor, role: 'Author') }
      let(:work) { build(:work, contributors: [contributor1, contributor2, contributor3]) }

      # TODO: implement order

      it 'creates array of Cocina::Models::Contributors' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor1.last_name}, #{contributor1.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              status: 'primary',
              # order: 1,
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [{ value: contributor2.full_name }],
              type: 'organization',
              # order: 2,
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor3.last_name}, #{contributor3.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              # order: 3,
              role: author_roles
            )
          ]
        )
      end
    end

    context 'with multipe person contributors and organization as non-author' do
      let(:contributor1) { build(:contributor, role: 'Author') }
      let(:contributor2) { build(:contributor, :with_org_contributor, role: 'Sponsor') }
      let(:contributor3) { build(:contributor, role: 'Author') }
      let(:work) { build(:work, contributors: [contributor1, contributor2, contributor3]) }

      # TODO: implement order

      it 'creates array of Cocina::Models::Contributors' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor1.last_name}, #{contributor1.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              status: 'primary',
              # order: 1,
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [{ value: contributor2.full_name }],
              type: 'organization',
              role: sponsor_roles
            ),
            Cocina::Models::Contributor.new(
              name: [
                {
                  value: "#{contributor3.last_name}, #{contributor3.first_name}",
                  type: 'inverted full name'
                }
              ],
              type: 'person',
              # order: 2,
              role: author_roles
            )
          ]
        )
      end
    end

    context 'with organization as funder' do
      let(:contributor) { build(:contributor, :with_org_contributor, full_name: 'Stanford University', role: 'Funder') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor per spec' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'organization',
              status: 'primary',
              role: [
                {
                  value: 'Funder',
                  source: stanford_self_deposit_source
                },
                {
                  value: 'funder',
                  code: 'fnd',
                  uri: 'http://id.loc.gov/vocabulary/relators/fnd',
                  source: marc_relator_source
                }
              ]
            )
          ]
        )
      end
    end

    # see description_generator_spec for example 12 - "Publisher and publication date entered by user"

    # see also description_generator_spec for example 13 - "Publisher entered by user, no publication date"
    context 'with publisher entered by user' do
      let(:contributor) do
        build(:contributor,
              :with_org_contributor, full_name: 'Stanford University Press', role: 'Publisher')
      end
      let(:work) { build(:work, contributors: [contributor]) }

      it 'does not create Cocina::Models::Contributor' do
        expect(cocina_model).to eq []
      end
    end
  end
end
