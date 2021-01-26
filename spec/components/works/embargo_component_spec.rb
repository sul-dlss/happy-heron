# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work, collection: collection) }
  let(:collection) { build(:collection, release_option: 'immediate') }

  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Manage release of this deposit for discovery and download after publication')
  end

  context 'when user can choose availablity' do
    let(:collection) { build(:collection, release_option: 'depositor-selects') }

    it 'renders the component' do
      expect(rendered.to_html)
        .to include('Select when the files in your deposit will be downloadable from the PURL page.')
    end
  end

  context 'when the collection is configured for immediate deposit' do
    it 'renders the component' do
      expect(rendered.to_html).to include 'immediately upon deposit.'
    end
  end

  context 'when the collection is configured for a specific date' do
    let(:collection) { build(:collection, release_option: 'delay', release_date: Date.parse('2030-09-07')) }

    it 'renders the component' do
      expect(rendered.to_html).to include 'starting on September 07, 2030.'
    end
  end

  context 'when collection access is depositor selects' do
    let(:work) { build(:work) }

    it 'renders the access selector' do
      expect(rendered.css('#access')).to be_present
    end
  end

  context 'when collection access is set to world' do
    let(:work) { build(:work) }

    before do
      work.collection.access = 'world'
    end

    it 'does not render the access selector' do
      expect(rendered.css('#access')).not_to be_present
    end
  end
end
