# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::FormComponent do
  let(:component) { described_class.new(work_form: work_form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build_stubbed(:work, collection: build(:collection, id: 7)) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
    work.collection.access = 'depositor-selects'
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Deposit', 'Save as draft', 'Discard draft', 'File', 'Add your files',
                  'Title of deposit and contact information',
                  'List authors and contributors',
                  'Enter dates related to your deposit',
                  'Describe your deposit',
                  'Manage release of this deposit',
                  'Select a license')
  end
end
