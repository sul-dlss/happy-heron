# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::ContributorsGenerator do
  subject(:cocina_model) { described_class.generate(work_version:, merge_stanford_and_organization:) }

  let(:merge_stanford_and_organization) { false }

  let(:cocina_props) { cocina_model.map(&:to_h) }

  let(:marc_relator_source) do
    {
      code: 'marcrelator',
      uri: 'http://id.loc.gov/vocabulary/relators/'
    }
  end

  let(:contributing_author_role) do
    {
      value: 'contributor',
      code: 'ctb',
      uri: 'http://id.loc.gov/vocabulary/relators/ctb',
      source: marc_relator_source
    }
  end

  let(:publisher_roles) do
    [
      {
        value: 'publisher',
        code: 'pbl',
        uri: 'http://id.loc.gov/vocabulary/relators/pbl',
        source: marc_relator_source
      }
    ]
  end

  let(:citation_status_notes) do
    [
      {
        value: 'false',
        type: 'citation status'
      }
    ]
  end

  context 'without marcrelator mapping' do
    let(:contributor) { build(:org_contributor, role: 'Conference') }
    let(:work_version) { build(:work_version, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor without marc relator role' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::Contributor.new({
                                            name: [{ value: contributor.full_name }],
                                            type: 'conference',
                                            status: 'primary',
                                            role: [
                                              {
                                                value: 'conference'
                                              }
                                            ],
                                            note: citation_status_notes
                                          }).to_h
        ]
      )
    end
  end

  context 'with DataCite creator mapping for role' do
    let(:contributor) { build(:person_contributor) }
    let(:work_version) { build(:work_version, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::Contributor.new({
                                            name: [
                                              {
                                                structuredValue: [
                                                  {
                                                    value: contributor.first_name,
                                                    type: 'forename'
                                                  },
                                                  {
                                                    value: contributor.last_name,
                                                    type: 'surname'
                                                  }
                                                ]
                                              }
                                            ],
                                            type: 'person',
                                            status: 'primary',
                                            role: [contributing_author_role],
                                            note: citation_status_notes
                                          }).to_h
        ]
      )
    end
  end

  # from https://github.com/sul-dlss/dor-services-app/blob/main/spec/services/cocina/mapping/descriptive/h2/contributor_h2_spec.rb
  # The contexts below match the spec names from above. The expected cocina props are copied directly.
  describe 'h2 mapping specification examples' do
    let(:cocina_props) do
      {
        contributor: cocina_model.map(&:to_h)
      }.compact_blank
    end

    let(:pub_date) do
      if work_version.published_edtf
        Cocina::Models::Event.new(
          type: 'publication',
          date: [
            {
              value: work_version.published_edtf.strftime('%Y-%m-%d'),
              encoding: { code: 'w3cdtf' },
              status: 'primary',
              type: 'publication'
            }
          ]
        )
      end
    end

    context 'with cited contributor with author role' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Author') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'author',
                                                    code: 'aut',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with multiple cited contributors' do
      let(:author1) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Author') }
      let(:author2) { build(:person_author, first_name: 'Leland', last_name: 'Stanford', role: 'Author') }
      let(:work_version) { build(:work_version, authors: [author1, author2]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'author',
                                                    code: 'aut',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Leland',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                role: [
                                                  {
                                                    value: 'author',
                                                    code: 'aut',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with cited organization' do
      let(:author1) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Data collector') }
      let(:author2) { build(:org_author, full_name: 'Stanford University', role: 'Sponsor') }
      let(:work_version) { build(:work_version, authors: [author1, author2]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'compiler',
                                                    code: 'com',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/com',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                role: [
                                                  {
                                                    value: 'sponsor',
                                                    code: 'spn',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/spn',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited organization' do
      let(:author) { build(:org_author, full_name: 'Stanford University', role: 'Host institution') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'host institution',
                                                    code: 'his',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/his',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with multiple cited organizations' do
      let(:author1) { build(:org_author, full_name: 'Stanford University', role: 'Host institution') }
      let(:author2) { build(:org_author, full_name: 'Department of English', role: 'Department') }
      let(:work_version) { build(:work_version, authors: [author1, author2]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'host institution',
                                                    code: 'his',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/his',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Department of English'
                                                  }
                                                ],
                                                type: 'organization',
                                                role: [
                                                  {
                                                    value: 'department'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited and uncited contributors' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Author') }
      let(:contributor) { build(:person_contributor, first_name: 'Leland', last_name: 'Stanford') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'author',
                                                    code: 'aut',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Leland',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                role: [
                                                  {
                                                    value: 'contributor',
                                                    code: 'ctb',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/ctb',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ],
                                                note: [
                                                  {
                                                    type: 'citation status',
                                                    value: 'false'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with uncited organization' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Data collector') }
      let(:contributor) { build(:org_contributor, full_name: 'Stanford University', role: 'Sponsor') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'compiler',
                                                    code: 'com',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/com',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                role: [
                                                  {
                                                    value: 'sponsor',
                                                    code: 'spn',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/spn',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ],
                                                note: [
                                                  {
                                                    type: 'citation status',
                                                    value: 'false'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with Event role' do
      let(:author) { build(:org_author, full_name: 'San Francisco Symphony Concert', role: 'Event') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'San Francisco Symphony Concert'
                                                  }
                                                ],
                                                type: 'event',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'event'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor and uncited contributor with Event role' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Event organizer') }
      let(:contributor) { build(:org_contributor, full_name: 'San Francisco Symphony Concert', role: 'Event') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'organizer',
                                                    code: 'orm',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/orm',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                type: 'event',
                                                name: [
                                                  {
                                                    value: 'San Francisco Symphony Concert'
                                                  }
                                                ],
                                                role: [
                                                  {
                                                    value: 'event'
                                                  }
                                                ],
                                                note: [
                                                  {
                                                    type: 'citation status',
                                                    value: 'false'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with Conference role' do
      let(:author) { build(:org_author, full_name: 'LDCX', role: 'Conference') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'LDCX'
                                                  }
                                                ],
                                                type: 'conference',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'conference'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor and uncited contributor with Conference role' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Speaker') }
      let(:contributor) { build(:org_contributor, full_name: 'LDCX', role: 'Conference') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'generates cocina' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'speaker',
                                                    code: 'spk',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/spk',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'LDCX'
                                                  }
                                                ],
                                                type: 'conference',
                                                role: [
                                                  {
                                                    value: 'conference'
                                                  }
                                                ],
                                                note: [
                                                  {
                                                    type: 'citation status',
                                                    value: 'false'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with Funder role' do
      let(:author) { build(:org_author, full_name: 'Stanford University', role: 'Funder') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'funder',
                                                    code: 'fnd',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/fnd',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor and uncited contributor with Funder role' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Data collector') }
      let(:contributor) { build(:org_contributor, full_name: 'Stanford University', role: 'Funder') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'compiler',
                                                    code: 'com',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/com',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University'
                                                  }
                                                ],
                                                type: 'organization',
                                                role: [
                                                  {
                                                    value: 'funder',
                                                    code: 'fnd',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/fnd',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ],
                                                note: [
                                                  {
                                                    type: 'citation status',
                                                    value: 'false'
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor with Publisher role' do
      let(:author) { build(:org_author, full_name: 'Stanford University Press', role: 'Publisher') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University Press'
                                                  }
                                                ],
                                                type: 'organization',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'publisher',
                                                    code: 'pbl',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end

    context 'with cited contributor and uncited contributor with Publisher role' do
      let(:author) { build(:person_author, first_name: 'Jane', last_name: 'Stanford', role: 'Author') }
      let(:contributor) { build(:org_contributor, full_name: 'Stanford University Press', role: 'Publisher') }
      let(:work_version) { build(:work_version, authors: [author], contributors: [contributor]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [
                                                  {
                                                    value: 'author',
                                                    code: 'aut',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/aut',
                                                    source: {
                                                      code: 'marcrelator',
                                                      uri: 'http://id.loc.gov/vocabulary/relators/'
                                                    }
                                                  }
                                                ]
                                              }).to_h,
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    value: 'Stanford University Press'

                                                  }
                                                ],
                                                type: 'organization', role: [
                                                                        {
                                                                          value: 'publisher',
                                                                          code: 'pbl',
                                                                          uri: 'http://id.loc.gov/vocabulary/relators/pbl',
                                                                          source: {
                                                                            code: 'marcrelator',
                                                                            uri: 'http://id.loc.gov/vocabulary/relators/'
                                                                          }
                                                                        }
                                                                      ],
                                                note: [
                                                  {
                                                    value: 'false',
                                                    type: 'citation status'
                                                  }
                                                ]
                                              }).to_h

            ]
          }
        )
      end
    end

    context 'with contributor with ORCID' do
      let(:author) do
        build(:person_author, first_name: 'Jane', last_name: 'Stanford', orcid: 'https://orcid.org/0000-0000-0000-0000')
      end
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          {
            contributor: [
              Cocina::Models::Contributor.new({
                                                name: [
                                                  {
                                                    structuredValue: [
                                                      {
                                                        value: 'Jane',
                                                        type: 'forename'
                                                      },
                                                      {
                                                        value: 'Stanford',
                                                        type: 'surname'
                                                      }
                                                    ]
                                                  }
                                                ],
                                                type: 'person',
                                                status: 'primary',
                                                role: [contributing_author_role],
                                                identifier: [
                                                  {
                                                    value: '0000-0000-0000-0000',
                                                    type: 'ORCID',
                                                    source: {
                                                      uri: 'https://orcid.org'
                                                    }
                                                  }
                                                ]
                                              }).to_h
            ]
          }
        )
      end
    end
  end

  context 'with contributor with affiliation' do
    let(:affiliation) { build(:affiliation, label: 'Stanford University') }
    let(:contributor) { build(:person_contributor, orcid: 'https://orcid.org/0000-0000-0000-0000', affiliations: [affiliation]) }
    let(:work_version) { build(:work_version, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::Contributor.new({
                                            name: [
                                              {
                                                structuredValue: [
                                                  {
                                                    value: contributor.first_name,
                                                    type: 'forename'
                                                  },
                                                  {
                                                    value: contributor.last_name,
                                                    type: 'surname'
                                                  }
                                                ]
                                              }
                                            ],
                                            type: 'person',
                                            status: 'primary',
                                            role: [contributing_author_role],
                                            identifier: [
                                              {
                                                value: '0000-0000-0000-0000',
                                                type: 'ORCID',
                                                source: {
                                                  uri: 'https://orcid.org'
                                                }
                                              }
                                            ],
                                            note: [
                                              {
                                                type: 'citation status',
                                                value: 'false'
                                              },
                                              {
                                                type: 'affiliation',
                                                value: 'Stanford University'
                                              }

                                            ]
                                          }).to_h
        ]
      )
    end
  end

  context 'when merge_stanford_and_organization is enabled' do
    let(:merge_stanford_and_organization) { true }

    context 'when there is a Stanford contributor with a degree granting institution role' do
      let(:author1) { build(:org_author, full_name: 'Stanford University', role: 'Degree granting institution') }
      let(:author2) { build(:org_author, full_name: 'Department of English', role: 'Department') }
      let(:work_version) { build(:work_version, authors: [author1, author2]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq([
                                     Cocina::Models::Contributor.new({
                                                                       name: [
                                                                         {
                                                                           structuredValue: [
                                                                             {
                                                                               value: 'Stanford University',
                                                                               identifier: [
                                                                                 {
                                                                                   uri: 'https://ror.org/00f54p054',
                                                                                   type: 'ROR',
                                                                                   source: {
                                                                                     code: 'ror'
                                                                                   }
                                                                                 }
                                                                               ]
                                                                             },
                                                                             { value: 'Department of English' }
                                                                           ]
                                                                         }
                                                                       ],
                                                                       type: 'organization',
                                                                       status: 'primary',
                                                                       role: [
                                                                         {
                                                                           value: 'degree granting institution',
                                                                           code: 'dgg',
                                                                           uri: 'http://id.loc.gov/vocabulary/relators/dgg',
                                                                           source: {
                                                                             code: 'marcrelator',
                                                                             uri: 'http://id.loc.gov/vocabulary/relators/'
                                                                           }
                                                                         }
                                                                       ]
                                                                     }).to_h

                                   ])
      end
    end

    context 'when there is a department without a Stanford contributor' do
      let(:author) { build(:org_author, full_name: 'Department of English', role: 'Department') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          [
            Cocina::Models::Contributor.new({
                                              name: [
                                                {
                                                  structuredValue: [
                                                    {
                                                      value: 'Stanford University',
                                                      identifier: [
                                                        {
                                                          uri: 'https://ror.org/00f54p054',
                                                          type: 'ROR',
                                                          source: {
                                                            code: 'ror'
                                                          }
                                                        }
                                                      ]
                                                    },
                                                    { value: 'Department of English' }
                                                  ]
                                                }
                                              ],
                                              type: 'organization',
                                              status: 'primary',
                                              role: [
                                                {
                                                  value: 'degree granting institution',
                                                  code: 'dgg',
                                                  uri: 'http://id.loc.gov/vocabulary/relators/dgg',
                                                  source: {
                                                    code: 'marcrelator',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/'
                                                  }
                                                }
                                              ]
                                            }).to_h

          ]
        )
      end
    end

    context 'when there is a Stanford contributor with a different role' do
      let(:author1) { build(:org_author, full_name: 'Stanford University', role: 'Host institution') }
      let(:author2) { build(:org_author, full_name: 'Department of English', role: 'Department') }
      let(:work_version) { build(:work_version, authors: [author1, author2]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          [
            Cocina::Models::Contributor.new({
                                              name: [
                                                {
                                                  value: 'Stanford University'
                                                }
                                              ],
                                              type: 'organization',
                                              status: 'primary',
                                              role: [
                                                {
                                                  value: 'host institution',
                                                  code: 'his',
                                                  uri: 'http://id.loc.gov/vocabulary/relators/his',
                                                  source: {
                                                    code: 'marcrelator',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/'
                                                  }
                                                }
                                              ]
                                            }).to_h,
            Cocina::Models::Contributor.new({
                                              name: [
                                                {
                                                  structuredValue: [
                                                    {
                                                      value: 'Stanford University',
                                                      identifier: [
                                                        {
                                                          uri: 'https://ror.org/00f54p054',
                                                          type: 'ROR',
                                                          source: {
                                                            code: 'ror'
                                                          }
                                                        }
                                                      ]
                                                    },
                                                    { value: 'Department of English' }
                                                  ]
                                                }
                                              ],
                                              type: 'organization',
                                              role: [
                                                {
                                                  value: 'degree granting institution',
                                                  code: 'dgg',
                                                  uri: 'http://id.loc.gov/vocabulary/relators/dgg',
                                                  source: {
                                                    code: 'marcrelator',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/'
                                                  }
                                                }
                                              ]
                                            }).to_h
          ]
        )
      end
    end

    context 'when there is a Stanford contributor with a degree granting institution role but no department' do
      let(:author) { build(:org_author, full_name: 'Stanford University', role: 'Degree granting institution') }
      let(:work_version) { build(:work_version, authors: [author]) }

      it 'creates Cocina::Models::Contributor props' do
        expect(cocina_props).to eq(
          [
            Cocina::Models::Contributor.new({
                                              name: [
                                                {
                                                  value: 'Stanford University'
                                                }
                                              ],
                                              identifier: [
                                                {
                                                  uri: 'https://ror.org/00f54p054',
                                                  type: 'ROR',
                                                  source: {
                                                    code: 'ror'
                                                  }
                                                }
                                              ],
                                              type: 'organization',
                                              status: 'primary',
                                              role: [
                                                {
                                                  value: 'degree granting institution',
                                                  code: 'dgg',
                                                  uri: 'http://id.loc.gov/vocabulary/relators/dgg',
                                                  source: {
                                                    code: 'marcrelator',
                                                    uri: 'http://id.loc.gov/vocabulary/relators/'
                                                  }
                                                }
                                              ]
                                            }).to_h

          ]
        )
      end
    end
  end

  context 'when no_citation_status_note is enabled' do
    let(:contributor) { build(:org_contributor, role: 'Conference') }
    let(:work_version) { build(:work_version, contributors: [contributor]) }

    before do
      allow(Settings).to receive(:no_citation_status_note).and_return(true)
    end

    it 'creates Cocina::Models::Contributor without citation status note' do
      expect(cocina_props).to eq(
        [
          Cocina::Models::Contributor.new({
                                            name: [{ value: contributor.full_name }],
                                            type: 'conference',
                                            status: 'primary',
                                            role: [
                                              {
                                                value: 'conference'
                                              }
                                            ]
                                          }).to_h
        ]
      )
    end
  end
end
