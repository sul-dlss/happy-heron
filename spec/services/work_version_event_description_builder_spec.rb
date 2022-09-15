# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkVersionEventDescriptionBuilder do
  subject(:result) { described_class.build(form) }

  let(:collection) { build(:collection, :depositor_selects_access, :depositor_selects_release_date) }
  let(:work_version) { create(:work_version_with_work, :with_no_subtype, collection: collection) }
  let(:work) { work_version.work }
  let(:form) { DraftWorkForm.new(work_version: work_version, work: work) }

  context 'when nothing has changed' do
    let(:params) do
      ActionController::Parameters.new(
        # TODO: to make realistic, add ALL the params that get passed in from the form
        work_type: work_version.work_type,
        title: work_version.title,
        abstract: work_version.abstract,
        citation: work_version.citation,
        subtype: work_version.subtype
      )
    end

    before do
      form.validate(params)
    end

    it { is_expected.to be_blank }
  end

  context 'when embargoed, then edited with no changes to embargo' do
    let(:embargo_date) { 11.months.from_now }
    let(:work_version) do
      create(:work_version_with_work, :with_no_subtype, embargo_date: embargo_date, collection: collection)
    end
    let(:params) do
      ActionController::Parameters.new(
        title: 'new title',
        release: 'embargo',
        'embargo_date(1i)' => embargo_date.year,
        'embargo_date(2i)' => embargo_date.month,
        'embargo_date(3i)' => embargo_date.day
      )
    end

    before do
      form.validate(params)
    end

    it 'description does not show embargo modified' do
      expect(result).to eq 'title of deposit modified'
    end
  end

  context 'when embargoed, then changes to embargo date' do
    let(:embargo_date) { 10.months.from_now }
    let(:new_embargo_date) { 11.months.from_now }
    let(:work_version) do
      create(:work_version_with_work, :with_no_subtype, embargo_date: embargo_date, collection: collection)
    end
    let(:params) do
      ActionController::Parameters.new(
        title: 'new title',
        release: 'embargo',
        'embargo_date(1i)' => new_embargo_date.year,
        'embargo_date(2i)' => new_embargo_date.month,
        'embargo_date(3i)' => new_embargo_date.day
      )
    end

    before do
      form.validate(params)
    end

    it 'description does show embargo modified' do
      expect(result).to eq 'title of deposit modified, embargo modified'
    end
  end

  context 'when not embargoed, then embargo set' do
    let(:new_embargo_date) { 11.months.from_now }
    let(:work_version) { create(:work_version_with_work, :with_no_subtype, collection: collection) }
    let(:params) do
      ActionController::Parameters.new(
        title: 'new title',
        release: 'embargo',
        'embargo_date(1i)' => new_embargo_date.year,
        'embargo_date(2i)' => new_embargo_date.month,
        'embargo_date(3i)' => new_embargo_date.day
      )
    end

    before do
      form.validate(params)
    end

    it 'description does show embargo modified' do
      expect(result).to eq 'title of deposit modified, embargo modified'
    end
  end

  context 'when embargoed, then embargo removed' do
    let(:embargo_date) { 10.months.from_now }
    let(:work_version) do
      create(:work_version_with_work, :with_no_subtype, embargo_date: embargo_date, collection: collection)
    end
    let(:params) do
      ActionController::Parameters.new(
        title: 'new title',
        release: 'immediate'
      )
    end

    before do
      form.validate(params)
    end

    it 'description does show embargo modified' do
      expect(result).to eq 'title of deposit modified, embargo modified'
    end
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

  context 'when file label has changed' do
    before do
      allow(AttachedFile).to receive(:new).and_return(AttachedFile.new)

      form.validate(
        attached_files: [
          { 'label' => 'a new label!', 'hide' => false, 'file' => '123782312abcdef' }
        ]
      )
    end

    it { is_expected.to include 'file description changed' }
  end

  context 'when file label has not changed' do
    before do
      allow(AttachedFile).to receive(:new).and_return(AttachedFile.new)

      form.validate(
        attached_files: [
          { 'label' => '', 'hide' => false, 'file' => '123782312abcdef' }
        ]
      )
    end

    it { is_expected.not_to include 'file description changed' }
  end

  context 'when title has changed' do
    before do
      form.validate(title: 'new title')
    end

    it { is_expected.to eq 'title of deposit modified' }
  end

  context 'when many fields have changed' do
    let(:params) do
      ActionController::Parameters.new(
        title: 'new title',
        abstract: 'foo',
        contact_emails: [{ 'email' => 'foo@bar.io' }],
        authors: [{ 'role_term' => 'person|Author', 'first_name' => 'Megan' }],
        contributors: [{ 'role_term' => 'person|Author', 'first_name' => 'Sara' }],
        related_links: [{ 'link_title' => 'Hey', 'url' => 'http://io.io' }],
        related_works: [{ 'citation' => 'Hey' }],
        'published(1i)' => '2020',
        'created(1i)' => '2020',
        keywords: [{ 'label' => 'Brown coal' }],
        release: 'embargo',
        'embargo_date(1i)' => '2021', 'embargo_date(2i)' => '3', 'embargo_date(3i)' => '3',
        license: 'ODbL-1.0',
        access: 'stanford',
        citation: 'Lorem ipsum',
        subtype: %w[foo bar],
        assign_doi: 'false',
        attached_files_attributes: { '0' =>
                      { 'label' => 'a label', '_destroy' => 'false', 'hide' => '0',
                        'file' => 'eyJfcmFpbHMiOnsibWVzc2FnZS...' } }
      )
    end

    before do
      allow(AttachedFile).to receive(:new).and_return(AttachedFile.new)

      form.validate(params)
    end

    it 'has a complete description' do
      expect(result).to eq 'title of deposit modified, abstract modified, ' \
                           'contact email modified, authors modified, contributors modified, ' \
                           'related links modified, related works modified, ' \
                           'publication date modified, creation date modified, ' \
                           'keywords modified, work subtypes modified, ' \
                           'citation modified, embargo modified, ' \
                           'visibility modified, license modified, ' \
                           'files added/removed, file description changed, assign DOI modified'
    end
  end

  context 'when a new work version and nothing has changed' do
    let(:user) { build(:user) }
    let(:collection) { build(:collection, required_license: 'CC0-1.0', release_option: 'immediate', access: 'world') }
    let(:work) { Work.new(collection: collection, depositor: user, owner: user) }
    let(:work_version) { WorkVersion.new(work: work) }

    context 'when nothing has changed' do
      before do
        form.validate(
          {
            'title' => '',
            'work_type' => 'text',
            'published(1i)' => '',
            'published(2i)' => '',
            'published(3i)' => '',
            'created_type' => 'single',
            'created(1i)' => '',
            'created(2i)' => '',
            'created(3i)' => '',
            'abstract' => '',
            'citation_auto' => ', . (2022). . Stanford Digital Repository. Available at :link will be ' \
                               'inserted here automatically when available:',
            'citation' => '',
            'default_citation' => 'true',
            'agree_to_terms' => '0',
            'globus' => 'false',
            'authors_attributes' => {
              '0' => {
                '_destroy' => '',
                'full_name' => '',
                'first_name' => '',
                'last_name' => '',
                'role_term' => 'person|Author',
                'weight' => '0',
                'orcid' => ''
              }
            },
            'contributors_attributes' => {
              '0' => {
                '_destroy' => '',
                'full_name' => '',
                'first_name' => '',
                'last_name' => '',
                'role_term' => 'person|Author', 'orcid' => ''
              }
            },
            'contact_emails_attributes' => {
              '0' => {
                '_destroy' => '',
                'email' => ''
              }
            },
            'keywords_attributes' => {
              '0' => {
                '_destroy' => '',
                'label' => '',
                'uri' => '',
                'cocina_type' => ''
              }
            },
            'related_works_attributes' => {
              '0' => {
                '_destroy' => '',
                'citation' => ''
              }
            },
            'related_links_attributes' => {
              '0' => {
                '_destroy' => '',
                'link_title' => '',
                'url' => ''
              }
            }
          }
        )
      end

      it { is_expected.to be_blank }
    end
  end
end
