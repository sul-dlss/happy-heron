# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EditLinkComponent, type: :component do
  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version, state: 'purl_reserved') }
  let(:anchor) { 'top' }
  let(:label) { 'A Small Letter B' }
  let(:rendered) do
    render_inline(described_class.new(work_version: work_version, anchor: anchor, label: label))
  end

  context 'with a work in purl reserved state' do
    before do
      allow(work_version).to receive(:purl_reservation?).and_return(true)
    end

    it 'renders a link with bootstap modal attributes' do
      expect(rendered.css('a[@data-bs-target="#workTypeModal"]')).to be_present
    end
  end

  context 'with a work in deposited state' do
    let(:work_version) { build_stubbed(:work_version, state: 'deposited') }

    before do
      allow(work_version).to receive(:purl_reservation?).and_return(false)
    end

    it 'renders a link without bootstap modal attributes' do
      expect(rendered.css('a[@data-bs-target="#workTypeModal"]')).not_to be_present
    end
  end
end
