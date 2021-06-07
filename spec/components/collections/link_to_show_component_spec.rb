# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::LinkToShowComponent, type: :component do
  let(:render) { render_inline(described_class.new(collection_version: collection_version)) }
  let(:collection_version) { build_stubbed(:collection_version, name: name) }
  let(:name) do
    'collection name'
  end

  it 'renders the collection name as a link' do
    expect(render.css('a').first['name']).to eq name
  end
end
