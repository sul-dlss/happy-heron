# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DatesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form, min_year: 1000, max_year: 2020)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html).to include('Enter dates related to your deposit')
  end

  context 'with a populated form with a date range' do
    let(:work) { build(:work, :published, :with_creation_date_range) }

    it 'renders the component' do
      expect(rendered.css('#work_published_year').first['value']).to eq '2020'
      expect(rendered.css('#work_published_month option[@selected="selected"]').first['value']).to eq '2'
      expect(rendered.css('#work_published_day option[@selected="selected"]').first['value']).to eq '14'

      expect(rendered.css('#created_type_range[@checked]')).to be_present
      expect(rendered.css('#created_type_single[@checked]')).not_to be_present

      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_range_start_day option[@selected="selected"]').first['value']).to eq '4'

      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '10'
      expect(rendered.css('#work_created_range_end_day option[@selected="selected"]').first['value']).to eq '31'
    end
  end

  context 'with a populated form with a single creation_date' do
    let(:work) { build(:work, :with_creation_date) }

    it 'renders the component' do
      expect(rendered.css('#created_type_single[@checked]')).to be_present
      expect(rendered.css('#created_type_range[@checked]')).not_to be_present

      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_day option[@selected="selected"]').first['value']).to eq '8'
    end
  end

  context 'with a populated form containing only year for single creation_date' do
    let(:year_only_creation_date) { EDTF.parse('2020') }
    let(:work) { build(:work, created_edtf: year_only_creation_date) }

    it 'renders the component without month or day selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]')).to match_array([])
      expect(rendered.css('#work_created_day option[@selected="selected"]')).to match_array([])
    end
  end

  context 'with a populated form containing year and month for single creation_date' do
    let(:year_month_creation_date) { EDTF.parse('2020-05') }
    let(:work) { build(:work, created_edtf: year_month_creation_date) }

    it 'renders the component without day selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_created_day option[@selected="selected"]')).to match_array([])
    end
  end
end
