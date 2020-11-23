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

  context 'when pending approval' do
    let(:work) { build_stubbed(:work, state: 'pending_approval') }

    context 'when not an approver' do
      before do
        allow(controller).to receive(:allowed_to?).and_return(false)
      end

      it 'renders the messge about review' do
        expect(rendered.css('.alert-warning').to_html).to include(
          'Your deposit has been sent for approval. You will receive an email once your deposit has been approved.'
        )
      end
    end

    context 'when an approver' do
      before do
        allow(controller).to receive(:allowed_to?).and_return(true)
      end

      it 'renders the messge about review' do
        expect(rendered.css('.alert-warning').to_html).to be_blank
      end
    end
  end
end
