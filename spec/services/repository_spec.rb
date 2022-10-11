# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Repository do
  describe 'valid_version?' do
    subject(:valid_version?) { described_class.valid_version?(druid:, h2_version:) }

    let(:druid) { 'druid:bb652bq1296' }

    let(:cocina_obj) { instance_double(Cocina::Models::DRO, version: 1) }

    before do
      allow(described_class).to receive(:find).and_return(cocina_obj)
    end

    context 'when the H2 version is one greater than the SDR version' do
      let(:h2_version) { 2 }

      it 'returns true' do
        expect(valid_version?).to be true
        expect(described_class).to have_received(:find).with(druid)
      end
    end

    context 'when the H2 version is not one greater than the SDR version' do
      let(:h2_version) { 1 }

      it 'returns false' do
        expect(valid_version?).to be false
      end
    end
  end
end
