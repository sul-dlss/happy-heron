# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressCollectionRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }
  let(:collection_version) { create(:collection_version_with_collection) }

  it 'renders the component' do
    expect(rendered.to_html).to include collection_version.name
  end
end
