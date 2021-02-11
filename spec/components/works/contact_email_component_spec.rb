# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContactEmailComponent, type: :component do
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:form) { ActionView::Helpers::FormBuilder.new('work', work_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.to_html).to include('Contact email')
  end
end
