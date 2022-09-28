# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DatesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(described_class.new(form:, min_year: 1000, max_year: 2020)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html).to include('Enter dates related to your deposit')
  end

  context 'with a populated form with a date range' do
    let(:work_version) { build(:work_version, :published, :with_creation_date_range) }

    it 'renders the component' do
      expect(rendered.css('#work_published_year').first['value']).to eq '2020'
      expect(rendered.css('#work_published_month option[@selected="selected"]').first['value']).to eq '2'
      expect(rendered.css('#work_published_day option[@selected="selected"]').first['value']).to eq '14'

      expect(rendered.css('#created_type[@checked]')).to be_present

      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_range_start_day option[@selected="selected"]').first['value']).to eq '4'

      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '10'
      expect(rendered.css('#work_created_range_end_day option[@selected="selected"]').first['value']).to eq '31'
    end
  end

  context 'with a populated form with an (legacy) approximate date range' do
    let(:approx_date_range) { EDTF.parse('2019-05?/2020-07?') }
    let(:work_version) { build(:work_version, created_edtf: approx_date_range) }

    it 'renders the component with both start and end (legacy) approximate checkbox selected' do
      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2019'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_created_range_approx0_').first.attribute('checked').value).to eq 'checked'
      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '7'
      expect(rendered.css('#work_created_range_approx3_').first.attribute('checked').value).to eq 'checked'
    end
  end

  context 'with a populated form with an approximate date range' do
    let(:approx_date_range) { EDTF.parse('2019-05~/2020-07~') }
    let(:work_version) { build(:work_version, created_edtf: approx_date_range) }

    it 'renders the component with both start and end approximate checkbox selected' do
      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2019'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_created_range_approx0_').first.attribute('checked').value).to eq 'checked'
      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '7'
      expect(rendered.css('#work_created_range_approx3_').first.attribute('checked').value).to eq 'checked'
    end
  end

  context 'with a populated form with an approximate backwards date range' do
    # Testing this due to how EDTF handles to < from
    let(:approx_date_range) { EDTF.parse('2020-07~/2019-05~') }
    let(:work_version) { build(:work_version, created_edtf: approx_date_range) }

    it 'renders the component with both start and end approximate checkbox selected' do
      expect(rendered.css('#work_created_range_start_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_range_start_month option[@selected="selected"]').first['value']).to eq '7'
      expect(rendered.css('#work_created_range_approx0_').first.attribute('checked').value).to eq 'checked'
      expect(rendered.css('#work_created_range_end_year').first['value']).to eq '2019'
      expect(rendered.css('#work_created_range_end_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_created_range_approx3_').first.attribute('checked').value).to eq 'checked'
    end
  end

  context 'with a populated form with a single creation_date' do
    let(:work_version) { build(:work_version, :with_creation_date) }

    it 'renders the component' do
      expect(rendered.css('#created_type[@checked]')).not_to be_present

      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]').first['value']).to eq '3'
      expect(rendered.css('#work_created_day option[@selected="selected"]').first['value']).to eq '8'
    end
  end

  context 'with a populated form containing only year for single creation_date' do
    let(:year_only_creation_date) { EDTF.parse('2020') }
    let(:work_version) { build(:work_version, created_edtf: year_only_creation_date) }

    it 'renders the component without month or day selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]')).to be_empty
      expect(rendered.css('#work_created_day option[@selected="selected"]')).to be_empty
    end
  end

  context 'with a populated form containing year and month for single creation_date' do
    let(:year_month_creation_date) { EDTF.parse('2020-05') }
    let(:work_version) { build(:work_version, created_edtf: year_month_creation_date) }

    it 'renders the component without day selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_month option[@selected="selected"]').first['value']).to eq '5'
      expect(rendered.css('#work_created_day option[@selected="selected"]')).to be_empty
    end
  end

  context 'with a populated form containing an (legacy) approximate date' do
    let(:creation_date) { EDTF.parse('2020-05-09?') }
    let(:work_version) { build(:work_version, created_edtf: creation_date) }

    it 'renders the component with the approximate check-box selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_approx0_').first.attribute('checked').value).to eq 'checked'
    end
  end

  context 'with a populated form containing an approximate date' do
    let(:creation_date) { EDTF.parse('2020-05-09~') }
    let(:work_version) { build(:work_version, created_edtf: creation_date) }

    it 'renders the component with the approximate check-box selected' do
      expect(rendered.css('#work_created_year').first['value']).to eq '2020'
      expect(rendered.css('#work_created_approx0_').first.attribute('checked').value).to eq 'checked'
    end
  end

  context 'with a different type of form' do
    before do
      allow(work_form.model_name).to receive(:param_key).and_return('draft_work')
    end

    it 'uses the param_key from the form' do
      expect(rendered.css('#draft_work_created_year')).to be_present
      expect(rendered.css('#draft_work_created_month')).to be_present
      expect(rendered.css('#draft_work_created_day')).to be_present
    end
  end
end
