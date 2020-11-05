# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::WorkFormComponent do
  let(:component) { described_class.new(work_form: work_form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work, collection: build(:collection, id: 7)) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(component) }

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Deposit your content', '1. File', 'Add your files',
                  'Title of deposit and contact information',
                  'List authors and contributors',
                  'Enter dates related to your deposit',
                  'Describe your deposit',
                  'Manage release of this deposit',
                  'Select a license')
    expect(rendered.css('.was-validated')).not_to be_present
  end

  context 'when there are errors' do
    before do
      work_form.validate({})
    end

    it 'renders the component errors' do
      expect(rendered.css('form.was-validated')).to be_present
    end
  end
end
