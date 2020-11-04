# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::KeywordsComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work_form) { WorkForm.new(work) }
  let(:work) { build(:work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.css('.keywords').to_html)
      .to be_present
    expect(rendered.css('.keywords-container.is-invalid')).not_to be_present
  end

  context 'when the keyword is not provided' do
    before do
      work_form.validate({})
    end

    it 'renders the component errors' do
      expect(rendered.css('.keywords-container.is-invalid')).to be_present
      expect(rendered.css('.keywords-container.is-invalid ~ .invalid-feedback')).to be_present
    end
  end
end
