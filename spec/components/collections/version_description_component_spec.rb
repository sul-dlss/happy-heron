# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::VersionDescriptionComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }
  let(:collection) { build_stubbed(:collection, head: collection_version) }
  let(:collection_form) { DraftCollectionVersionForm.new(collection_version) }

  context 'with a first draft' do
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'does not render the component' do
      expect(rendered.to_html).to be_blank
    end
  end

  context 'with a deposited collection' do
    let(:collection_version) { build_stubbed(:collection_version, state: :deposited) }

    it 'renders the component' do
      expect(rendered.to_html).to include('Version your collection *')
    end
  end
end
