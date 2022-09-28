# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::EventsGenerator do
  subject(:events) { normalize_events(described_class.generate(work_version:)) }

  let(:publisher_roles) do
    [
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
  end
  let(:deposit_publication_event) do
    {
      type: 'deposit',
      date: [
        {
          type: 'publication',
          value: '2019-01-01',
          encoding: { code: 'edtf' }
        }
      ]
    }
  end

  context 'without published date' do
    let(:work_version) do
      build(:work_version, :with_work)
    end

    it 'created a deposit publication event' do
      expect(events).to eq(normalize_events([
                                              deposit_publication_event
                                            ]))
    end
  end

  context 'when work has multiple versions' do
    let(:work) do
      build(:work)
    end
    let(:work_version2) do
      build(:valid_deposited_work_version, published_at: Time.zone.parse('2017-01-01'), work:)
    end
    let!(:work_version3) do
      build(:valid_deposited_work_version, published_at: Time.zone.parse('2018-01-01'), work:)
    end
    let(:work_version) do
      build(:valid_deposited_work_version, work:)
    end

    before do
      work.work_versions = [work_version2, work_version3, work_version]
      work.head = work_version
    end

    it 'created a deposit publication event and deposit modification events' do
      expect(events).to eq(normalize_events([
                                              {
                                                type: 'deposit',
                                                date: [
                                                  {
                                                    type: 'publication',
                                                    value: '2017-01-01',
                                                    encoding: { code: 'edtf' }
                                                  }
                                                ]
                                              },
                                              {
                                                type: 'deposit',
                                                date: [
                                                  {
                                                    type: 'modification',
                                                    value: '2018-01-01',
                                                    encoding: { code: 'edtf' }
                                                  }
                                                ]
                                              },
                                              {
                                                type: 'deposit',
                                                date: [
                                                  {
                                                    type: 'modification',
                                                    value: '2019-01-01',
                                                    encoding: { code: 'edtf' }
                                                  }
                                                ]
                                              }
                                            ]))
    end
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   example 12
  context 'when publisher and publication date are entered by user' do
    let(:contributor) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :with_work, :published, :with_contact_emails,
            contributors: [contributor],
            title: 'Test title')
    end

    it 'creates event of type publication with date' do
      expect(events).to eq(normalize_events([
                                              deposit_publication_event,
                                              {
                                                type: 'publication',
                                                contributor: [
                                                  {
                                                    name: [{ value: contributor.full_name }],
                                                    role: publisher_roles,
                                                    type: 'organization'
                                                  }
                                                ],
                                                date: [
                                                  {
                                                    encoding: { code: 'edtf' },
                                                    value: '2020-02-14',
                                                    type: 'publication',
                                                    status: 'primary'
                                                  }
                                                ]
                                              }
                                            ]))
    end
  end

  # see https://github.com/sul-dlss-labs/cocina-descriptive-metadata/blob/master/h2_cocina_mappings/h2_to_cocina_contributor.txt
  #   example 13
  #   Note:  no top level contributor -- publisher is under event
  context 'when publisher entered by user, no publication date' do
    let(:contributor) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :with_work, :with_contact_emails,
            contributors: [contributor], title: 'Test title')
    end

    it 'creates event of type publication without date' do
      expect(events).to eq(normalize_events([
                                              deposit_publication_event,
                                              {
                                                type: 'publication',
                                                contributor: [
                                                  {
                                                    name: [{ value: contributor.full_name }],
                                                    role: publisher_roles,
                                                    type: 'organization'
                                                  }
                                                ]
                                              }
                                            ]))
    end
  end

  context 'when author, publisher and publication date are entered by user' do
    let(:person_author) { build(:person_author, role: 'Author') }
    let(:pub_contrib) { build(:org_contributor, role: 'Publisher') }
    let(:work_version) do
      build(:work_version, :with_work, :published, :with_contact_emails,
            authors: [person_author],
            contributors: [pub_contrib], title: 'Test title')
    end

    it 'creates event of type publication with date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'publication',
                                 contributor: [
                                   {
                                     name: [{ value: pub_contrib.full_name }],
                                     role: publisher_roles,
                                     type: 'organization'
                                   }
                                 ],
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-02-14',
                                     type: 'publication',
                                     status: 'primary'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when publication date of year only' do
    let(:work_version) do
      build(:work_version, :with_work, :published_with_year_only)
    end

    it 'creates event of type publication with year only date' do
      expect(events).to eq(
        normalize_events([
                           deposit_publication_event,
                           {
                             type: 'publication',
                             date: [
                               {
                                 encoding: { code: 'edtf' },
                                 value: '2021',
                                 type: 'publication',
                                 status: 'primary'
                               }
                             ]
                           }
                         ])
      )
    end
  end

  context 'when publication date of year and month only' do
    let(:work_version) do
      build(:work_version, :with_work, :published_with_year_month_only)
    end

    it 'creates event of type publication with year and month only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'publication',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2021-04',
                                     type: 'publication',
                                     status: 'primary'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when creation date of year only' do
    let(:work_version) do
      build(:work_version, :with_work, :with_creation_date_year_only)
    end

    it 'creates event of type creation with year only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020',
                                     type: 'creation'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when creation date of year and month only' do
    let(:work_version) do
      build(:work_version, :with_work, :with_creation_date_year_month_only)
    end

    it 'creates event of type creation with year and month only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-06',
                                     type: 'creation'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when approximate creation date' do
    let(:work_version) do
      build(:work_version, :with_work, :with_approximate_creation_date)
    end

    it 'creates event of type creation with approximate date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-03-08',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when legacy approximate creation date' do
    let(:work_version) do
      build(:work_version, :with_work, :with_legacy_approximate_creation_date)
    end

    it 'creates event of type creation with approximate date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-03-08',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when approximate creation date of year only' do
    let(:work_version) do
      build(:work_version, :with_work, :with_approximate_creation_date_year_only)
    end

    it 'creates event of type creation with approximate year only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when legacy approximate creation date of year only' do
    let(:work_version) do
      build(:work_version, :with_work, :with_legacy_approximate_creation_date_year_only)
    end

    it 'creates event of type creation with approximate year only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when approximate creation date of year and month only date' do
    let(:work_version) do
      build(:work_version, :with_work, :with_approximate_creation_date_year_month_only)
    end

    it 'creates event of type creation with approximate year and month only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-06',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when legacy approximate creation date of year and month only date' do
    let(:work_version) do
      build(:work_version, :with_work, :with_legacy_approximate_creation_date_year_month_only)
    end

    it 'creates event of type creation with approximate year and month only date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     value: '2020-06',
                                     type: 'creation',
                                     qualifier: 'approximate'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when approximate creation date range' do
    let(:work_version) do
      build(:work_version, :with_work, :with_approximate_creation_date_range)
    end

    it 'creates event of type creation with approximate date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     structuredValue: [
                                       { value: '2020-03-04', type: 'start' },
                                       { value: '2020-10-31', type: 'end' }
                                     ],
                                     qualifier: 'approximate',
                                     type: 'creation'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end

  context 'when legacy approximate creation date range' do
    let(:work_version) do
      build(:work_version, :with_work, :with_legacy_approximate_creation_date_range)
    end

    it 'creates event of type creation with approximate date' do
      expect(events).to eq(normalize_events(
                             [
                               deposit_publication_event,
                               {
                                 type: 'creation',
                                 date: [
                                   {
                                     encoding: { code: 'edtf' },
                                     structuredValue: [
                                       { value: '2020-03-04', type: 'start' },
                                       { value: '2020-10-31', type: 'end' }
                                     ],
                                     qualifier: 'approximate',
                                     type: 'creation'
                                   }
                                 ]
                               }
                             ]
                           ))
    end
  end
end

def normalize_events(events)
  events.map { |event| Cocina::Models::Event.new(event).to_h }
end
