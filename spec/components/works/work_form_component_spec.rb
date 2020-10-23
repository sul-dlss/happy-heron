# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::WorkFormComponent do
  let(:component) { described_class.new(work_form: work_form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }

  before do
    allow(component).to receive(:form_with).and_yield(form)
  end

  it 'renders the component' do
    expect(render_inline(component).to_html)
      .to include('Deposit your work', '1. File', 'Add your files',
                  'Title of deposit and contact information',
                  'List authors and contributors',
                  'Enter dates related to your deposit',
                  'Describe your deposit', 'Manage release of this item',
                  'Select a license')
  end
end
