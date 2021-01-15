# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::LicenseComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }

  context 'with no license selected' do
    it 'renders the component' do
      expect(rendered.to_html).to include('Select a license')
    end
  end

  context 'with a license selected' do
    let(:work) { build(:work, license: 'ODbL-1.0') }

    it 'renders the component with the correct license selected' do
      expect(rendered.to_html).to include('<option selected value="ODbL-1.0">')
    end
  end
end
