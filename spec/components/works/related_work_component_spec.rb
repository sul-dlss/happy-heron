# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::RelatedWorkComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:related_works) do
    [
      build_stubbed(:related_work, citation: 'First Citation'),
      build_stubbed(:related_work, citation: 'Second Citation')
    ]
  end
  let(:rendered) { render_inline(described_class.new(form: form)) }
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version, related_works: related_works) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }

  it 'renders a delete button for all works but the first' do
    expect(rendered.css('button[@aria-label="Remove Second Citation"]')).to be_present
    expect(rendered.css('button[@aria-label="Remove First Citation"]')).not_to be_present
  end
end
