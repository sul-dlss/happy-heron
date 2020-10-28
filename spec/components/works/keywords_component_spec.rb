# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::KeywordsComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work_form) { WorkForm.new(work) }
  let(:work) { build(:work) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).css('.keywords').to_html)
      .to be_present
  end
end
