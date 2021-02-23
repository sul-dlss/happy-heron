# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::InformationComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  context 'when displaying a collection' do
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the information component' do
      expect(rendered.css('table').to_html).to include collection_version.version.to_s
      expect(rendered.css('table').to_html).to include collection_version.collection.creator.sunetid
    end
  end
end
