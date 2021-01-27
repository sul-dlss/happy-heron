# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::PublicationDateComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
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
end
