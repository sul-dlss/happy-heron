# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::HistoryComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when viewing a collection' do
    let(:collection) { build_stubbed(:collection) }

    it 'renders the history component' do
      expect(rendered.css('table').to_html).to include('History')
    end
  end
end
