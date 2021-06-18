# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::InformationComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  context 'when a first version collection' do
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the information component' do
      expect(rendered.css('table').to_html).to include '1 - initial version'
      expect(rendered.css('table').to_html).to include collection_version.collection.creator.sunetid
    end
  end

  context 'when a subsequent version collection' do
    let(:collection_version) { build_stubbed(:collection_version, version: 2, description: 'changed the title') }

    it 'renders the information component' do
      expect(rendered.css('table').to_html).to include '2 - changed the title'
    end
  end
end
