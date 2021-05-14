# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::KeywordsComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.to_html).to include('Keyword')
    expect(rendered.to_html).to include('+ Add another keyword')
  end
end
