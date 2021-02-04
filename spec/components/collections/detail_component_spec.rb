# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::DetailComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when a first draft' do
    let(:collection) { build_stubbed(:collection, :with_contact_emails) }

    it 'renders the detail component' do
      expect(rendered.css('table').to_html).to include('MyString').twice
      expect(rendered.css('table').to_html).to include('io@io.io').once
    end
  end
end
