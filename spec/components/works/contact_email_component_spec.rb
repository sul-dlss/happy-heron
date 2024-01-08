# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContactEmailComponent, type: :component do
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:form) { ActionView::Helpers::FormBuilder.new('work', work_form, vc_test_controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:, key: 'work.contact_email')) }

  it 'renders the component' do
    expect(rendered.to_html).to include('Contact email')
    expect(rendered.to_html).to include('+ Add another email')
  end
end
