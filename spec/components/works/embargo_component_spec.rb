# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Manage release of this deposit for discovery and download after publication')
  end

  it 'checks the immediate release radio button' do
    expect(rendered.css('#release_immediate[@checked]')).to be_present
    expect(rendered.css('#release_embargo[@checked]')).not_to be_present
  end

  context 'when the embargo date is set' do
    let(:embargo_date) { work.embargo_date }
    let(:work) { build(:work, :embargoed) }

    it 'checks the embargo release radio button' do
      expect(rendered.css('#release_embargo[@checked]')).to be_present
      expect(rendered.css('#release_immediate[@checked]')).not_to be_present
    end

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
