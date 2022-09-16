# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::HistoryComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection:)) }

  context 'when viewing a collection' do
    let(:collection) { build_stubbed(:collection) }
    let(:table) { rendered.css('table').to_html }

    it 'renders the history component w/ expected event table header labels' do
      expect(table).to include('History')
      expect(table).to include('Modified by')
      expect(table).to include('Last modified')
      expect(table).to include('Description of changes')
    end
  end
end
