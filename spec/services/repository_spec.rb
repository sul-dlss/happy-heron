# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Repository do
  let(:druid) { 'druid:bb652bq1296' }

  describe '.find' do
    let(:cocina) do
      {
        cocinaVersion: Cocina::Models::VERSION,
        externalIdentifier: druid,
        type: Cocina::Models::ObjectType.book,
        label: 'Test DRO',
        version: cocina_version,
        description: {
          title: [{ value: 'Test DRO' }],
          purl: "https://purl.stanford.edu/#{druid.delete_prefix('druid:')}"
        },
        access: { view: 'world', download: 'world' },
        administrative: { hasAdminPolicy: 'druid:hy787xj5878' },
        identification: { sourceId: 'sul:abc123' },
        structural: {}
      }
    end

    let(:cocina_version) { 1 }

    before do
      allow(SdrClient::Find).to receive(:run).and_return(cocina.to_json)
      allow(SdrClientAuthenticator).to receive(:login)
    end

    it 'ensures the SDR client is authenticated' do
      described_class.find(druid)
      expect(SdrClientAuthenticator).to have_received(:login).once
    end

    it 'returns a cocina object instance' do
      expect(described_class.find(druid)).to be_a(Cocina::Models::DRO)
    end
  end

  describe '.valid_version?' do
    subject(:valid_version?) { described_class.valid_version?(druid:, h2_version:) }

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
      let(:h2_version) { 3 }

      it 'returns false' do
        expect(valid_version?).to be false
      end
    end

    context 'when the H2 version and SDR version are 1 (PURL reservation)' do
      let(:h2_version) { 1 }

      it 'returns true' do
        expect(valid_version?).to be true
      end
    end

    context 'when the H2 version and SDR version are same (embargo lifted)' do
      let(:h2_version) { 2 }
      let(:cocina_version) { 2 }

      it 'returns true' do
        expect(valid_version?).to be true
      end
    end
  end
end
