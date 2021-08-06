# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CitationModalComponent, type: :component do
  let(:rendered) { render_inline(described_class.new) }

  it 'renders the component' do
    expect(rendered.css('#citationModal h5')).to be_present
    expect(rendered.css('#citationModal #citationValue')).to be_present
  end
end
