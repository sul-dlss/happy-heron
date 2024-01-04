# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CitationComponent, type: :component do
  subject(:link) { rendered.css('a').first }

  let(:rendered) { render_inline(described_class.new(work_version:)) }

  context 'when the state is deposited' do
    let(:work_version) { build(:work_version, :deposited) }

    it 'renders a button' do
      expect(link['data-bs-target']).to eq '#citationModal'
      expect(link['data-controller']).to eq 'show-citation'
      expect(link['disabled']).not_to be_present
    end
  end

  context 'when the state is purl_reserved' do
    let(:work_version) { build(:work_version, :purl_reserved) }

    it 'renders a disabled button' do
      expect(link['disabled']).to be_present
    end
  end

  context 'when the state is first_draft' do
    let(:work_version) { build(:work_version, :first_draft) }

    it 'renders a disabled button' do
      expect(link['disabled']).to be_present
    end
  end
end
