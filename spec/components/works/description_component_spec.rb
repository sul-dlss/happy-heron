# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DescriptionComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Describe your deposit')
  end
end
