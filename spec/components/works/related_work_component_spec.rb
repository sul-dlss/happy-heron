# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::RelatedWorkComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:related_works) do
    [
      build_stubbed(:related_work, citation: 'First Citation'),
      build_stubbed(:related_work, citation: 'Second Citation')
    ]
  end
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version, related_works:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  it 'renders a delete button for all works' do
    expect(rendered.css('button[@aria-label="Remove related work Second Citation"]')).to be_present
    expect(rendered.css('button[@aria-label="Remove related work First Citation"]')).to be_present
  end
end
