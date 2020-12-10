# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Manage release of this deposit for discovery and download after publication')
  end

  context 'when the embargo date is set' do
    let(:embargo_date) { work.embargo_date }
    let(:work) { build(:work, :embargoed) }

    it 'renders the year' do
      expect(rendered.css('#work_embargo_year option[@selected]').first['value'])
        .to eq embargo_date.year.to_s
    end

    it 'renders the month' do
      expect(rendered.css('#work_embargo_month option[@selected]').first['value'])
        .to eq embargo_date.month.to_s
    end

    it 'renders the day' do
      expect(rendered.css('#work_embargo_day option[@selected]').first['value'])
        .to eq embargo_date.day.to_s
    end
  end
end
