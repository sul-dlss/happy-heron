# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AllCollectionsRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection:, counts:)) }
  let(:collection) { build_stubbed(:collection, head: collection_version) }
  let(:collection_version) { build_stubbed(:collection_version) }
  let(:counts) { {} }

  context 'with a new, first draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }

    it 'adds Draft to the label' do
      expect(rendered.to_html).to include 'Draft'
      expect(rendered.to_html).not_to include 'Version Draft'
    end
  end

  context 'with a version draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :version_draft) }

    it 'adds Version Draft to the label' do
      expect(rendered.to_html).to include 'Version Draft'
    end
  end

  context 'with a decommissioned collection' do
    let(:collection_version) { build_stubbed(:collection_version, :decommissioned) }

    it 'adds Decommission to the label' do
      expect(rendered.to_html).to include 'Decommissioned'
    end
  end

  context 'with a deposited collection' do
    let(:collection_version) { build_stubbed(:collection_version, :deposited) }

    it 'does not change the label' do
      expect(rendered.to_html).not_to include 'Version Draft'
      expect(rendered.to_html).not_to include 'Draft'
      expect(rendered.to_html).not_to include 'Decommissioned'
    end
  end

  context 'with a collection that has works' do
    let(:counts) { { 'total' => 5 } }
    let(:url) { Rails.application.routes.url_helpers.collection_works_path(collection) }

    it 'links to the works' do
      expect(rendered.css("a[href=\"#{url}\"]").text).to eq '5'
    end
  end
end
