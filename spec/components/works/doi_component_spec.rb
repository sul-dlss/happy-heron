# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DoiComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build(:collection, doi_option: doi_option) }
  let(:doi_option) { 'yes' }
  let(:work) { build(:work, collection: collection, doi: doi) }
  let(:doi) { nil }
  let(:work_version) { build(:work_version, work: work) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('DOI assignment')
  end

  context 'when DOI is already assigned' do
    let(:doi) { '10.25740/wg432jy0214' }

    it 'renders the component' do
      expect(rendered.to_html)
        .to include('The DOI assigned to this work is <a href="https://doi.org/10.25740/wg432jy0214">https://doi.org/10.25740/wg432jy0214</a>.')
    end
  end

  context 'when the collection is configured for a DOI to be automatically assigned' do
    it 'renders the component' do
      expect(rendered.to_html).to include 'A DOI will be assigned.'
    end
  end

  context 'when the collection is configured for a DOI to not be assigned' do
    let(:doi_option) { 'no' }

    it 'renders the component' do
      expect(rendered.to_html).to include 'A DOI will not be assigned.'
    end
  end

  context 'when the collection is configured depositor to select whether to assign DOI' do
    let(:doi_option) { 'depositor-selects' }

    it 'renders the component' do
      expect(rendered.to_html).to include 'Do you want a DOI to be assigned to your deposit?'
    end
  end
end
