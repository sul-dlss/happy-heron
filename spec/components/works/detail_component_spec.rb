# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::DetailComponent, type: :component do
  let(:instance) { described_class.new(work_version: work_version) }
  let(:rendered) { render_inline(instance) }

  before do
    allow(work_version.work.collection).to receive(:head).and_return(build_stubbed(:collection_version))
  end

  context 'when a first draft' do
    let(:work_version) { build_stubbed(:work_version) }

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).to include('Draft - Not deposited')
    end
  end

  context 'when deposited' do
    let(:work_version) { build_stubbed(:work_version, :deposited) }

    it 'renders the draft title' do
      expect(rendered.css('.state').to_html).not_to include('Not deposited')
    end
  end

  context 'when pending approval' do
    let(:work_version) { build_stubbed(:work_version, :pending_approval) }

    it 'renders the messge about review' do
      expect(rendered.css('.alert-warning.visible-to-depositor').to_html).to include(
        'Your deposit has been sent for approval. You will receive an email once your deposit has been approved.'
      )
    end
  end

  context 'when rejected' do
    let(:rejection_reason) { 'Why did you dye your hair chartreuse?' }
    let(:work) { build_stubbed(:work) }
    let(:work_version) { build_stubbed(:work_version, :rejected, work: work) }

    before do
      create(:event, description: rejection_reason, event_type: 'reject', eventable: work)
    end

    it 'renders the rejection alert' do
      expect(rendered.css('.alert-danger').to_html).to include(rejection_reason)
    end
  end

  describe 'events' do
    let(:work) { build_stubbed(:work, events: [build_stubbed(:event, description: 'Add more keywords')]) }
    let(:work_version) { build_stubbed(:work_version, work: work) }

    it 'renders the event' do
      expect(rendered.css('#events').to_html).to include 'Add more keywords'
    end
  end

  describe '#created' do
    let(:work_version) { build_stubbed(:work_version, created_edtf: EDTF.parse('1982-09')) }

    it 'renders the date' do
      expect(instance.created).to eq '1982-09'
    end
  end

  describe '#published' do
    let(:work_version) { build_stubbed(:work_version, published_edtf: EDTF.parse('1987-04')) }

    it 'renders the date' do
      expect(instance.published).to eq '1987-04'
    end
  end
end
