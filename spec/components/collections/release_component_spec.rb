# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::ReleaseComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collection' do
    let(:release_option) { collection.release_option }
    let(:access) { collection.access }
    let(:collection) { build_stubbed(:collection) }

    it 'renders the release component' do
      expect(rendered.css('table').to_html).to include(release_option)
      expect(rendered.css('table').to_html).to include(access)
    end
  end
end
