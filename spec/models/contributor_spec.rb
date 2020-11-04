# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor do
  subject(:contributor) { build(:contributor) }

  it 'has a first name' do
    expect(contributor.first_name).to be_present
  end

  it 'has a last name' do
    expect(contributor.last_name).to be_present
  end

  it 'belongs to a work' do
    expect(contributor.work).to be_a(Work)
  end

  describe '.grouped_options' do
    subject(:grouped_options) { described_class.grouped_options }

    it 'makes groups with headings' do
      expect(grouped_options).to eq [['Individual',
                                      [['Author', 'person|Author'],
                                       ['Composer', 'person|Composer'],
                                       ['Contributing author', 'person|Contributing author'],
                                       ['Copyright holder', 'person|Copyright holder'],
                                       ['Creator', 'person|Creator'],
                                       ['Data collector', 'person|Data collector'],
                                       ['Data contributor', 'person|Data contributor'],
                                       ['Editor', 'person|Editor'],
                                       ['Event organizer', 'person|Event organizer'],
                                       ['Interviewee', 'person|Interviewee'],
                                       ['Interviewer', 'person|Interviewer'],
                                       ['Performer', 'person|Performer'],
                                       ['Photographer', 'person|Photographer'],
                                       ['Primary thesis advisor',
                                        'person|Primary thesis advisor'],
                                       ['Principal investigator', 'person|Principal investigator'],
                                       ['Researcher', 'person|Researcher'],
                                       ['Software developer', 'person|Software developer'],
                                       ['Speaker', 'person|Speaker'],
                                       ['Thesis advisor', 'person|Thesis advisor']]],
                                     ['Organization',
                                      [['Author', 'organization|Author'],
                                       ['Conference', 'organization|Conference'],
                                       ['Contributing author', 'organization|Contributing author'],
                                       ['Copyright holder', 'organization|Copyright holder'],
                                       ['Data collector', 'organization|Data collector'],
                                       ['Data contributor', 'organization|Data contributor'],
                                       ['Degree granting institution', 'organization|Degree granting institution'],
                                       ['Event', 'organization|Event'],
                                       ['Event organizer', 'organization|Event organizer'],
                                       ['Funder', 'organization|Funder'],
                                       ['Host institution', 'organization|Host institution'],
                                       ['Issuing body', 'organization|Issuing body'],
                                       ['Publisher', 'organization|Publisher'],
                                       ['Research group', 'organization|Research group'],
                                       ['Sponsor', 'organization|Sponsor']]]]
    end
  end

  describe '#role_term=' do
    it 'assigns both role and contributor_type' do
      contributor.role_term = 'organization|Contributing author'
      expect(contributor.contributor_type).to eq 'organization'
      expect(contributor.role).to eq 'Contributing author'
    end
  end

  describe '#role_term' do
    it 'reads both role and contributor_type' do
      expect(contributor.role_term).to eq 'person|Contributing author'
    end
  end
end
