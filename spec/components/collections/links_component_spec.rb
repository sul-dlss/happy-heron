# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::LinksComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  context 'when it has links' do
    let(:collection_version) { build_stubbed(:collection_version, :with_related_links) }

    it 'renders the links' do
      expect(rendered.css('caption').to_html).to include 'Links to related information'
      expect(rendered.css('tbody tr td p').size).to eq 2
    end
  end

  context 'without links' do
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders a message that says they have none' do
      expect(rendered.css('tbody td').to_html).to include 'None provided'
    end
  end
end
