# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::InformationComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collection' do
    let(:version) { collection.version.to_s }
    let(:creator) { collection.creator.to_s }
    let(:collection) { build_stubbed(:collection) }

    it 'renders the information component' do
      expect(rendered.css('table').to_html).to include(version)
      expect(rendered.css('table').to_html).to include(creator)
    end
  end
end
