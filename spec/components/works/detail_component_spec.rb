# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DetailComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work: work)) }

  context 'when a first draft' do
    let(:work) { build_stubbed(:work) }

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).to include('Draft - Not deposited')
    end
  end

  context 'when deposted' do
    let(:work) { build_stubbed(:work, state: 'deposited') }

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).not_to include('Not deposited')
    end
  end
end
