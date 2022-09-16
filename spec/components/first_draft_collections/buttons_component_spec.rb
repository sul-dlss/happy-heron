# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FirstDraftCollections::ButtonsComponent do
  let(:component) { described_class.new(form:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version) }
  let(:work_form) { CreateCollectionForm.new(collection:, collection_version:) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  context 'when creating a collection' do
    it 'renders submit button as "Deposit"' do
      expect(rendered.css('input[value="Deposit"]')).to be_present
    end

    it 'renders the save draft button' do
      expect(rendered.css('input[value="Save as draft"]')).to be_present
    end

    it 'returns to dashboard on cancel' do
      expect(rendered.to_html).to have_link 'Cancel', href: '/dashboard'
    end
  end

  context 'when editing a draft collection' do
    let(:collection) { build_stubbed(:collection) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders submit button as "Deposit"' do
      expect(rendered.css('input[value="Deposit"]')).to be_present
    end

    it 'renders the save draft button' do
      expect(rendered.css('input[value="Save as draft"]')).to be_present
    end

    it 'returns to collection details on cancel' do
      expect(rendered.to_html).to have_link 'Cancel', href: "/collection_versions/#{collection_version.id}"
    end
  end
end
