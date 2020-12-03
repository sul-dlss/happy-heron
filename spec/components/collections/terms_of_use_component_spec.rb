# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::TermsOfUseComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  context 'when displaying a collection' do
    let(:license) { collection.default_license }
    let(:collection) { build_stubbed(:collection) }

    it 'renders the terms of use component' do
      expect(rendered.css('table').to_html).to include(license)
    end
  end
end
