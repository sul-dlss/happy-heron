# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::PublicationDateComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:rendered) { render_inline(described_class.new(form: form, min_year: 999, max_year: 2040)) }

  context 'when there is an error' do
    before do
      work_form.errors.add(:published_edtf, 'must be in the past')
    end

    it 'renders the message and adds invalid styles' do
      expect(rendered.css('.is-invalid ~ .invalid-feedback').text).to eq 'must be in the past'
      expect(rendered.css('#work_published_year.is-invalid')).to be_present
      expect(rendered.css('#work_published_month.is-invalid')).to be_present
      expect(rendered.css('#work_published_day.is-invalid')).to be_present
    end
  end

  context 'with a populated form containing only year for publication_date' do
    let(:year_only_pub_date) { EDTF.parse('2020') }
    let(:work_version) { build(:work_version, published_edtf: year_only_pub_date) }

    it 'renders the component without month or day selected' do
      expect(rendered.css('#work_published_year').first['value']).to eq '2020'
      expect(rendered.css('#work_published_month option[@selected="selected"]')).to be_empty
      expect(rendered.css('#work_published_day option[@selected="selected"]')).to be_empty
    end
  end

  context 'with a populated form containing year and month for publication_date' do
    let(:year_month_pub_date) { EDTF.parse('2020-05') }
    let(:work_version) { build(:work_version, published_edtf: year_month_pub_date) }

    it 'renders the component without day selected' do
      expect(rendered.css('#work_published_year').first['value']).to eq '2020'
      expect(rendered.css('#work_published_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_published_day option[@selected="selected"]')).to be_empty
    end
  end

  context 'with a different type of form' do
    before do
      allow(work_form.model_name).to receive(:param_key).and_return('draft_work')
    end

    it 'uses the param_key from the form' do
      expect(rendered.css('#draft_work_published_year')).to be_present
      expect(rendered.css('#draft_work_published_month')).to be_present
      expect(rendered.css('#draft_work_published_day')).to be_present
    end
  end
end
