# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DetailComponent, type: :component do
  let(:instance) { described_class.new(work_version:) }
  let(:rendered) { render_inline(instance) }
  let(:user) { build(:user, name: 'Pyotr Kropotkin', email: 'kropot00@stanford.edu') }
  let(:user_with_groups) { UserWithGroups.new(user:, groups: []) }

  before do
    allow(vc_test_controller).to receive_messages(
      current_user: user,
      user_with_groups:
    )
    allow(work_version.work.collection).to receive(:head).and_return(build_stubbed(:collection_version))
  end

  context 'when a first draft' do
    let(:work_version) { build_stubbed(:work_version) }

    before do
      work_version.work.depositor = user
    end

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).to include('Draft - Not deposited')
      expect(rendered.to_html).to include '1 - initial version'
      expect(rendered.to_html).to include 'kropot00 (Pyotr Kropotkin)'
    end
  end

  context 'when deposited' do
    let(:work) { create(:work, :with_druid) }
    let(:work_version) do
      build_stubbed(:work_version, :deposited, version: 2, version_description: 'changed the title', user_version: 3,
                                               work:)
    end

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).not_to include('Not deposited')
      expect(rendered.to_html).to include '2 - changed the title'
    end

    context 'when user_versions_ui_enabled enabled' do
      before do
        allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
      end

      it 'renders the user_version' do
        expect(rendered.to_html).to include '3 - changed the title'
      end
    end
  end

  context 'when user_versions_ui_enabled' do
    let(:work) { create(:work, :with_druid) }

    before do
      allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
    end

    context 'with multiple user versions' do
      let(:work_version) do
        build_stubbed(:work_version, :deposited, version: 4, version_description: 'changed the files', user_version: 3,
                                                 work:)
      end

      it 'renders links to previous user versions' do
        expect(rendered.to_html).to include 'Previous version(s)'
        expect(rendered.to_html).to include 'https://purl.stanford.edu/bc123df4567/version/2'
      end
    end

    context 'when no previous user versions' do
      let(:work_version) do
        build_stubbed(:work_version, :deposited, version: 1, user_version: 1, version_description: nil, work:)
      end

      it 'does not render previous versions' do
        expect(rendered.to_html).not_to include 'Previous version(s)'
        expect(rendered.to_html).to include 'Current version'
        expect(rendered.css('td').to_html).not_to include '1 -'
        expect(rendered.css('td').to_html).to include '1'
      end
    end

    context 'when null user version' do
      let(:work_version) do
        build_stubbed(:work_version, :deposited, version: 1, user_version: nil, work:)
      end

      it 'does not render previous versions' do
        expect(rendered.to_html).not_to include 'Previous version(s)'
      end
    end
  end

  context 'when pending approval' do
    let(:work_version) { build_stubbed(:work_version, :pending_approval) }

    it 'renders the messge about review' do
      expect(rendered.css('.alert-warning.visible-to-depositor').to_html).to include(
        'Your deposit has been sent for approval. You will receive an email once your deposit has been approved.'
      )
    end
  end

  context 'when rejected' do
    let(:rejection_reason) { 'Why did you dye your hair chartreuse?' }
    let(:work) { build_stubbed(:work) }
    let(:work_version) { build_stubbed(:work_version, :rejected, work:) }

    before do
      create(:event, description: rejection_reason, event_type: 'reject', eventable: work)
    end

    it 'renders the rejection alert' do
      expect(rendered.css('.alert-danger').to_html).to include(rejection_reason)
    end
  end

  context 'when fetching globus files' do
    let(:work_version) { build_stubbed(:work_version, :fetch_globus_first_draft) }

    it 'renders the message about transferring files taking time' do
      expect(rendered.css('.globus-wait').to_html).to include(
        'Transferring your files from Globus. This could take some time depending on file size.'
      )
    end
  end

  describe 'events' do
    let(:work) { build_stubbed(:work, events:) }
    let(:events) do
      [
        build_stubbed(:event, description: 'Add more keywords'),
        build_stubbed(:embargo_lifted_event)
      ]
    end
    let(:work_version) { build_stubbed(:work_version, work:) }

    it 'renders the event' do
      expect(rendered.css('#events').to_html).to include('Add more keywords', 'Embargo lifted')
    end
  end

  describe 'authors and contributors' do
    let(:work_version) { build_stubbed(:work_version, authors: [author1, author2], contributors: [contributor]) }
    let(:author1) { build_stubbed(:person_author, orcid: 'https://orcid.org/0000-0002-1825-0097') }
    let(:author2) { build_stubbed(:person_author) }
    let(:contributor) { build_stubbed(:person_contributor, orcid: 'https://orcid.org/0000-0002-1825-0098') }

    it 'renders the authors and contributors table' do
      expect(rendered.css('#authors a').to_html).to include('https://orcid.org/0000-0002-1825-0097')
      expect(rendered.css('#contributors a').to_html).to include('https://orcid.org/0000-0002-1825-0098')
      # No link for author without ORCID.
      expect(rendered.css('#authors').search('a').size).to eq 1
      expect(rendered.css('#contributors').search('a').size).to eq 1
    end
  end

  describe 'DOI settings' do
    context 'with a DOI' do
      let(:work_version) { build_stubbed(:work_version, :deposited, version: 2, work:) }
      let(:work) { build_stubbed(:work, doi: '10.25740/bc123df4567') }

      it 'renders the doi_link' do
        expect(rendered.to_html).to include 'DOI assigned (see above)'
      end
    end

    context 'when DOI was requested' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, assign_doi: true) }

      it 'renders the doi setting' do
        expect(rendered.to_html).to include 'DOI not assigned'
      end
    end

    context 'when DOI was refused' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, assign_doi: false, collection:) }
      let(:collection) { build_stubbed(:collection, doi_option: 'depositor-selects') }

      it 'renders the doi setting' do
        expect(rendered.to_html).to include 'Opted out of receiving a DOI'
      end
    end

    context "when collection doesn't permit DOIs" do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: true) }
      let(:collection) { build_stubbed(:collection, doi_option: 'no') }

      it 'renders the doi setting' do
        expect(rendered.to_html).to include 'DOI will not be assigned'
      end
    end

    context 'when collection automatically assigns DOI' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: false) }
      let(:collection) { build_stubbed(:collection, doi_option: 'yes') }

      it 'renders the doi setting' do
        expect(rendered.to_html).to include 'DOI not assigned'
      end
    end
  end

  describe '#created' do
    let(:work_version) { build_stubbed(:work_version, created_edtf: edtf) }

    context 'with a plain date' do
      let(:edtf) { EDTF.parse('1987-04') }

      it 'renders the date' do
        expect(instance.created).to eq '1987-04'
      end
    end

    context 'with an interval' do
      let(:edtf) { EDTF.parse('1987-04/2020') }

      it 'renders the date' do
        expect(instance.created).to eq '1987-04 - 2020'
      end
    end

    context 'with an aprox interval' do
      let(:edtf) { EDTF.parse('1987-04?/2020?') }

      it 'renders the date' do
        expect(instance.created).to eq 'ca. 1987-04 - ca. 2020'
      end
    end

    context 'with a nil date' do
      let(:edtf) { nil }

      it 'renders the date' do
        expect(instance.created).to be_nil
      end
    end
  end

  describe '#published' do
    let(:work_version) { build_stubbed(:work_version, published_edtf: EDTF.parse('1982-09')) }

    it 'renders the date' do
      expect(instance.published).to eq '1982-09'
    end
  end

  describe '#work_type_label' do
    let(:work_version) { build_stubbed(:work_version, work_type: 'software, multimedia') }

    it 'returns the work type label' do
      expect(instance.work_type_label).to eq('Software/<wbr>Code')
    end

    it 'renders the expected label' do
      expect(rendered.to_html).to include('Software/Code')
    end
  end
end
