# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::DoiComponent, type: :component do
  subject(:details) { render_inline(instance) }

  let(:instance) { described_class.new(work_version:) }

  context 'with a DOI' do
    let(:work_version) { build_stubbed(:work_version, :deposited, version: 2, work:) }
    let(:work) { build_stubbed(:work, doi: '10.25740/bc123df4567') }

    it 'renders the doi_link' do
      expect(details.css('a[href="https://doi.org/10.25740/bc123df4567"]').to_html)
        .to include 'https://doi.org/10.25740/bc123df4567'
    end
  end

  context 'with a collection set to automatically assign a DOI' do
    let(:collection) { build_stubbed(:collection, doi_option: 'yes') }

    context 'with reserved PURL' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: false, druid: 'druid:bc123df4567') }

      it 'renders the doi setting' do
        expect(details.to_html).to include 'DOI will become available once the work has been deposited.'
      end
    end

    context 'when it is a first_draft without a reserved PURL' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: false) }

      it 'renders the doi setting' do
        expect(details.to_html).to include 'DOI will become available once the work has been deposited.'
      end
    end

    context 'when it is a version_draft without a reserved PURL' do
      let(:work_version) { build_stubbed(:work_version, :version_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: false) }

      it 'renders the doi setting' do
        expect(details.to_html).to include 'DOI will become available once a new version is deposited.'
      end
    end
  end

  context 'with a collection set to depositor-selects' do
    let(:collection) { build_stubbed(:collection, doi_option: 'depositor-selects') }

    context 'when they choose no and have a reserved purl' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: false, druid: 'druid:bc123df4567') }

      it 'renders the doi setting' do
        expect(details.to_html).to include 'A DOI has not been assigned to this item.'
      end
    end

    context 'when they choose yes without a reserved purl' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:, assign_doi: true) }

      it 'renders the doi setting' do
        expect(details.to_html).to include 'DOI will become available once the work has been deposited.'
      end
    end
  end

  context 'with a collection set to not permit DOI' do
    let(:collection) { build_stubbed(:collection, doi_option: 'no') }

    context 'when the work does not have a doi' do
      let(:work_version) { build_stubbed(:work_version, :first_draft, work:) }
      let(:work) { build_stubbed(:work, collection:) }

      it 'renders the DOI setting' do
        expect(details.to_html).to include 'A DOI will not be assigned.'
      end
    end

    context 'when the work has a DOI' do
      let(:work_version) { build_stubbed(:work_version, :deposited, work:) }
      let(:work) { build_stubbed(:work, collection:, doi: '10.25740/bc123df4567') }

      it 'renders the doi_link' do
        expect(details.css('a[href="https://doi.org/10.25740/bc123df4567"]').to_html)
          .to include 'https://doi.org/10.25740/bc123df4567'
      end
    end
  end
end
