# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkVersionEventDescriptionBuilder do
  subject(:result) { described_class.build(form) }

  let(:work_version) { create(:work_version_with_work, collection: build(:collection)) }
  let(:work) { work_version.work }
  let(:form) { DraftWorkForm.new(work_version: work_version, work: work) }

  context 'when nothing has changed' do
    it { is_expected.to be_blank }
  end

  context 'when file visibility has changed' do
    before do
      allow(AttachedFile).to receive(:new).and_return(AttachedFile.new)

      form.validate(
        attached_files: [
          { 'label' => 'xml.svg', 'hide' => true, 'file' => '123782312abcdef' }
        ]
      )
    end

    it { is_expected.to include 'file visibility changed' }
  end

  context 'when title has changed' do
    before do
      form.validate(title: 'new title')
    end

    it { is_expected.to eq 'title of deposit modified' }
  end

  context 'when many fields have changed' do
    before do
      allow(AttachedFile).to receive(:new).and_return(AttachedFile.new)

      form.validate(title: 'new title', abstract: 'foo',
                    contact_emails: [{ 'email' => 'foo@bar.io' }],
                    authors: [{ 'role_term' => 'person|Author', 'first_name' => 'Megan' }],
                    contributors: [{ 'role_term' => 'person|Author', 'first_name' => 'Sara' }],
                    related_links: [{ 'link_title' => 'Hey', 'url' => 'http://io.io' }],
                    related_works: [{ 'citation' => 'Hey' }],
                    published_edtf: '2020', created_edtf: '2020',
                    keywords: [{ 'label' => 'Brown coal' }],
                    license: 'http://cc.org/cc0-1.0',
                    access: 'stanford',
                    embargo_date: '2099-07-01',
                    citation: 'Lorem ipsum',
                    subtype: %w[foo bar],
                    attached_files: [
                      { 'label' => 'xml.svg', 'hide' => false, 'file' => '123782312abcdef' }
                    ])
    end

    it 'has a complete description' do
      expect(result).to eq 'title of deposit modified, abstract modified, ' \
                           'contact email modified, authors modified, contributors modified, ' \
                           'related links modified, related works modified, ' \
                           'publication date modified, creation date modified, ' \
                           'keywords modified, work subtypes modified, ' \
                           'citation modified, embargo modified, ' \
                           'visibility modified, license modified, ' \
                           'files added/removed, file description changed'
    end
  end
end
