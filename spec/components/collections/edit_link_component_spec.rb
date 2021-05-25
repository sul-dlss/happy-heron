# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::EditLinkComponent, type: :component do
  let(:rendered) { render_inline(instance) }
  let(:instance) do
    described_class.new(collection_version: collection_version,
                        anchor: '#desc',
                        label: 'Edit description')
  end

  context 'when allowed_to update' do
    let(:collection_version) { build_stubbed(:collection_version) }

    before do
      allow(controller).to receive(:allowed_to?).and_return(true)
    end

    it 'renders the link' do
      expect(rendered.css('a span').first['class']).to eq 'fas fa-pencil-alt edit'
    end
  end

  context 'when not allowed_to update' do
    let(:collection_version) { build_stubbed(:collection_version) }

    before do
      allow(controller).to receive(:allowed_to?).and_return(false)
    end

    it 'does not render the link' do
      expect(rendered.css('a')).to be_empty
    end
  end
end
