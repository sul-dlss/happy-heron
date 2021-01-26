# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DescriptionComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new('work', work_form, controller.view_context, {}) }
  let(:work) { build_stubbed(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Describe your deposit')
  end

  it 'has a checkbox with a label' do
    expect(rendered.css('#work_subtype_article')).to be_present
    expect(rendered.css("label[for='work_subtype_article']")).to be_present
  end
end
