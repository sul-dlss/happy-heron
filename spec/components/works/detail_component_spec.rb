# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DetailComponent, type: :component do
  let(:instance) { described_class.new(work: work) }
  let(:rendered) { render_inline(instance) }

  context 'when a first draft' do
    let(:work) { build_stubbed(:work) }

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).to include('Draft - Not deposited')
    end
  end

  context 'when deposited' do
    let(:work) { build_stubbed(:work, :deposited) }

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

  context 'when rejected' do
    let(:rejection_reason) { 'Why did you dye your hair chartreuse?' }
    let(:work) { create(:work, :rejected) }

    before do
      allow(controller).to receive(:allowed_to?).and_return(true)
      create(:event, description: rejection_reason, event_type: 'reject', eventable: work)
    end

    it 'renders the rejection alert' do
      expect(rendered.css('.alert-danger').to_html).to include(rejection_reason)
    end
  end

  describe 'events' do
    let(:work) { build_stubbed(:work, events: [build_stubbed(:event, description: 'Add more keywords')]) }

    it 'renders the event' do
      expect(rendered.css('#events').to_html).to include 'Add more keywords'
    end
  end

  describe '#created' do
    let(:work) { build_stubbed(:work, created_edtf: EDTF.parse('1982-09')) }

    it 'renders the date' do
      expect(instance.created).to eq '1982-09'
    end
  end

  describe '#published' do
    let(:work) { build_stubbed(:work, published_edtf: EDTF.parse('1987-04')) }

    it 'renders the date' do
      expect(instance.published).to eq '1987-04'
    end
  end
end
