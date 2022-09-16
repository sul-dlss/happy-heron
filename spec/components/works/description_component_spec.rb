# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DescriptionComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new('work', work_form, controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(described_class.new(form:)) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form:)).to_html)
      .to include('Describe your deposit')
  end

  it 'has a checkbox with a label' do
    expect(rendered.css('#work_subtype_government_document')).to be_present
    expect(rendered.css("label[for='work_subtype_government_document']")).to be_present
  end
end
