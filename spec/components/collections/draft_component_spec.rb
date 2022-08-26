# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::DraftComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  context 'when a first draft' do
    let(:collection_version) { build_stubbed(:collection_version, state: 'first_draft') }

    it 'renders the component' do
      expect(rendered.to_html).to include('Draft')
    end
  end

  context 'when a version draft' do
    let(:collection_version) { build_stubbed(:collection_version, state: 'version_draft') }

    it 'renders the component' do
      expect(rendered.to_html).to include('Draft')
    end
  end

  context 'when not a draft' do
    let(:collection_version) { build_stubbed(:collection_version, state: 'deposited') }

    it 'renders the component' do
      expect(rendered.to_html).not_to include('Draft')
    end
  end
end
