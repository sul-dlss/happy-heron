# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressCollectionRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }
  let(:collection) { build_stubbed(:collection) }

  it 'renders the component' do
    expect(rendered.to_html).to include collection.name
  end
end
