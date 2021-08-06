# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::ReleaseComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }
  let(:collection_version) { build_stubbed(:collection_version) }

  context 'when displaying a collection' do
    let(:access) { collection.access }
    let(:collection) { build_stubbed(:collection, head: collection_version) }

    it 'renders the release component' do
      expect(rendered.css('table').to_html).to include('Immediately')
      expect(rendered.css('table').to_html).to include(access)
    end
  end

  context 'when displaying a collection with depositor selects the release' do
    let(:collection) do
      build_stubbed(:collection, release_option: 'depositor-selects', release_duration: '3 years',
                                 head: collection_version)
    end
    let(:rendered) { render_inline(described_class.new(collection: collection)) }
    let(:message) { 'depositor selects release date at no more than 3 years from date of deposit' }

    it 'renders the release component with more detail regarding the release' do
      expect(rendered.css('table').to_html).to include(message)
    end
  end

  context 'when displaying a collection with a delayed release' do
    let(:collection) do
      build_stubbed(:collection, release_option: 'delay', release_duration: '2 years', head: collection_version)
    end
    let(:rendered) { render_inline(described_class.new(collection: collection)) }

    it 'renders the release component with a delayed option' do
      expect(rendered.css('table').to_html).to include('2 years from date of deposit')
    end
  end
end
