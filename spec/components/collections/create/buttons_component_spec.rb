# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Create::ButtonsComponent do
  let(:component) { described_class.new(form: form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version) }
  let(:work_form) { CreateCollectionForm.new(collection: collection, collection_version: collection_version) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  it 'renders submit button as "Deposit"' do
    expect(rendered.css('input[value="Deposit"]')).to be_present
  end

  # we are temporarily hiding the save draft button collection creation, renable this test and
  # remove the following one when the button is added back
  # see https://github.com/sul-dlss/happy-heron/issues/1250 and components/collections/create/button_compontent.html.erb
  xit 'renders the save draft button' do
    expect(rendered.css('input[value="Save as draft"]')).to be_present
  end

  it 'temporary: it does not renders the save draft button' do
    expect(rendered.css('input[value="Save as draft"]')).not_to be_present
  end
end
