# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DatesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form, min_year: 1000, max_year: 2020)) }

  it 'renders the component' do
    expect(rendered.to_html).to include('Enter dates related to your deposit')
  end

  context 'with a populated form with a date range' do
    let(:work) { build(:work, :published, :with_creation_date_range) }

    it 'renders the component' do
      expect(rendered.css('#work_published_year').first['value']).to eq '2020'
      expect(rendered.css('#work_published_month option[@selected="selected"]').first['value']).to eq '2'
      expect(rendered.css('#work_published_day option[@selected="selected"]').first['value']).to eq '14'

      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_range_start_day option[@selected="selected"]').first['value']).to eq '4'

      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '10'
      expect(rendered.css('#work_created_range_end_day option[@selected="selected"]').first['value']).to eq '31'
    end
  end

  context 'with a populated form with a single craeation_date' do
    let(:work) { build(:work, :with_creation_date) }

    it 'renders the component' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_day option[@selected="selected"]').first['value']).to eq '8'
    end
  end
end
