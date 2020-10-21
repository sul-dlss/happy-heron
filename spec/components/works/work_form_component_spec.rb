# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::WorkFormComponent do
  let(:component) { described_class.new(work: work) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }
  let(:work) { build(:work) }

  before do
    allow(component).to receive(:form_with).and_yield(form)
  end

  it 'renders the component' do
    expect(render_inline(component).to_html)
      .to include('Deposit your work', '1. File', 'Add your files',
                  'Title of deposit and contact information',
                  'List authors and contributors',
                  'Date content was created',
                  'Describe your deposit', 'Manage release of this item', 'Terms of use and license')
  end
end
