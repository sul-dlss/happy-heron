# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::VersionDescriptionComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form: form)) }
  let(:collection) { build_stubbed(:collection, head: collection_version) }
  let(:collection_form) { CreateCollectionForm.new(collection: collection, collection_version: collection_version) }

  context 'with a first draft' do
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'does not renders the component' do
      expect(rendered.to_html).not_to include('Version your work')
    end
  end
end
