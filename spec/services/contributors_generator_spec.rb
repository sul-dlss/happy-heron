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
      source: {
        value: 'DataCite properties'
      }
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
        source: {
          value: 'DataCite contributor types'
        }
      )
    ]
  end
  let(:event_form) do
    Cocina::Models::DescriptiveValue.new(
      value: 'Event',
      type: 'resource types',
      source: {
        value: 'DataCite resource types'
      }
    )
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
            role: contributing_author_roles
          )
        ]
      )
    end
  end

  context 'with single name with multiple roles mapping to DataCite creator property' do
    xit 'TODO: possibly covered with h2 mapping specs ... tune in soon'
  end

  # from https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  describe 'h2 mapping specification examples' do
    context 'with person with single role' do
      let(:contributor) { build(:contributor, role: 'Data collector') }
      let(:work) { build(:work, contributors: [contributor]) }

      # TODO: add status primary

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

      it 'ContributorsGenerator.form_from_contributors returns []' do
        expect(described_class.form_from_contributors(work: work)).to eq []
      end
    end

    context 'with person with multiple roles, one maps to DataCite creator property' do
      xit 'TODO: https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt#L50'
    end

    context 'with organization with single role' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Host institution') }
      let(:work) { build(:work, contributors: [contributor]) }

      # TODO: add status primary

      it 'creates Cocina::Models::Contributor without marc relator role' do
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'organization',
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
      xit 'TODO: https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt#L150'
    end

    context 'with conference as contributor' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Conference') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor' do
        # TODO: add status primary
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'conference',
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

      it 'ContributorsGenerator.form_from_contributors returns populated form attribute' do
        form = described_class.form_from_contributors(work: work)

        expect(form).to eq([event_form])
      end
    end

    context 'with event as contributor' do
      let(:contributor) { build(:contributor, :with_org_contributor, role: 'Event') }
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor with DataCite role' do
        # TODO: add status primary
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'event',
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

      it 'ContributorsGenerator.form_from_contributors returns populated form attribute' do
        form = described_class.form_from_contributors(work: work)

        expect(form).to eq([event_form])
      end
    end

    context 'with multiple person contributors' do
      let(:contributor1) { build(:contributor, role: 'Author') }
      let(:contributor2) { build(:contributor, role: 'Author') }
      let(:work) { build(:work, contributors: [contributor1, contributor2]) }

      it 'creates array of Cocina::Models::Contributor, one for each person contributor' do
        # TODO: add order
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
        # TODO: add status primary / order
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

      it 'creates array of Cocina::Models::Contributors' do
        # TODO: add status primary / order
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
              role: author_roles
            ),
            Cocina::Models::Contributor.new(
              name: [{ value: contributor2.full_name }],
              type: 'organization',
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

      it 'creates array of Cocina::Models::Contributors' do
        # TODO: add status primary / order
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
        # TODO: add status primary
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'organization',
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

    context 'with publisher and publication date entered by user' do
      xit 'TODO: https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt#L671'
    end

    context 'with publisher entered by user' do
      let(:contributor) do
        build(:contributor,
              :with_org_contributor, full_name: 'Stanford University Press', role: 'Publisher')
      end
      let(:work) { build(:work, contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor per spec' do
        # TODO: add status primary
        expect(cocina_model).to eq(
          [
            Cocina::Models::Contributor.new(
              name: [{ value: contributor.full_name }],
              type: 'organization',
              role: [
                {
                  value: 'Publisher',
                  source: stanford_self_deposit_source
                },
                {
                  value: 'publisher',
                  code: 'pbl',
                  uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                  source: marc_relator_source
                }
              ]
            )
          ]
        )
      end
    end
  end
end
