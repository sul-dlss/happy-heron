# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::ContributorsGenerator do
  subject(:cocina_model) { described_class.generate(work_version: work_version) }

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

  describe '.events_from_publisher_contributors' do
    context 'with no pub_date' do
      context 'with no publisher' do
        let(:contributor) { build(:person_contributor) }
        let(:work_version) { build(:work_version, contributors: [contributor]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work_version: work_version) }

        it 'returns empty Array' do
          expect(cocina_model).to eq []
        end
      end

      context 'with multiple publishers' do
        let(:org_contrib1) { build(:org_contributor, role: 'Publisher') }
        let(:org_contrib2) { build(:org_contributor, role: 'Publisher') }
        let(:work_version) { build(:work_version, contributors: [org_contrib1, org_contrib2]) }
        let(:cocina_model) { described_class.events_from_publisher_contributors(work_version: work_version) }

        it 'returns Array of populated cocina model events, one for each publisher' do
          expect(cocina_props).to eq(
            [
              {
                type: 'publication',
                contributor: [
                  {
                    name: [{ value: org_contrib1.full_name }],
                    role: publisher_roles,
                    type: 'organization'
                  }
                ]
              },
              {
                type: 'publication',
                contributor: [
                  {
                    name: [{ value: org_contrib2.full_name }],
                    role: publisher_roles,
                    type: 'organization'
                  }
                ]
              }
            ]
          )
        end
      end
    end

    context 'with a pub date' do
      let(:pub_date_value) do
        [
          {
            value: work_version.published_edtf,
            encoding: { code: 'edtf' },
            type: 'publication'
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
        let(:contributor) { build(:person_contributor) }
        let(:work_version) { build(:work_version, contributors: [contributor]) }
        let(:cocina_model) do
          described_class.events_from_publisher_contributors(work_version: work_version, pub_date: pub_date)
        end

        it 'returns empty Array' do
          expect(cocina_model).to eq []
        end
      end

      context 'with multiple publishers' do
        let(:org_contrib1) { build(:org_contributor, role: 'Publisher') }
        let(:org_contrib2) { build(:org_contributor, role: 'Publisher') }
        let(:work_version) { build(:work_version, contributors: [org_contrib1, org_contrib2]) }
        let(:cocina_model) do
          described_class.events_from_publisher_contributors(work_version: work_version, pub_date: pub_date)
        end

        it 'returns Array of populated cocina model events, one for each publisher' do
          expect(cocina_props).to eq(
            [
              {
                type: 'publication',
                date: pub_date_value,
                contributor: [
                  {
                    name: [{ value: org_contrib1.full_name }],
                    role: publisher_roles,
                    type: 'organization'
                  }
                ]
              },
              {
                type: 'publication',
                date: pub_date_value,
                contributor: [
                  {
                    name: [{ value: org_contrib2.full_name }],
                    role: publisher_roles,
                    type: 'organization'
                  }
                ]
              }
            ]
          )
        end
      end
    end
  end

  context 'without marcrelator mapping' do
    let(:contributor) { build(:org_contributor, role: 'Conference') }
    let(:work_version) { build(:work_version, contributors: [contributor]) }

    it 'creates Cocina::Models::Contributor without marc relator role' do
      expect(cocina_props).to eq(
        [
          {
            name: [{ value: contributor.full_name }],
            type: 'conference',
            status: 'primary',
            role: [
              {
                value: 'conference'
              }
            ],
            note: citation_status_notes
          }
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
          {
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
          }
        ]
      )
    end
  end

  # from https://github.com/sul-dlss/dor-services-app/blob/main/spec/services/cocina/mapping/descriptive/h2/contributor_h2_spec.rb
  # The contexts below match the spec names from above. The expected cocina props are copied directly.
  describe 'h2 mapping specification examples' do
    let(:cocina_props) do
      {
        contributor: cocina_model.map(&:to_h),
        event: described_class.events_from_publisher_contributors(work_version: work_version,
                                                                  pub_date: pub_date).map(&:to_h)
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
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              }
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
              {
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
              },
              {
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
              }
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
              {
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
              }
            ],
            event: [
              {
                type: 'publication',
                contributor: [
                  {
                    name: [
                      {
                        value: 'Stanford University Press'
                      }
                    ],
                    type: 'organization',
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
                  }
                ]
              }
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
              {
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
              }
            ],
            event: [
              {
                type: 'publication',
                contributor: [
                  {
                    name: [
                      {
                        value: 'Stanford University Press'
                      }
                    ],
                    type: 'organization',
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
                  }
                ]
              }
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
              {
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
              }
            ]
          }
        )
      end
    end
  end
end
