# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileGenerator do
  let(:model) { described_class.generate(work: work, attached_file: attached_file) }
  let(:work) { build(:work) }

  describe '#access' do
    subject { model.access }

    context 'when file is visible' do
      let(:attached_file) { create(:attached_file, :with_file, work: work) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(access: 'world', download: 'world') }
    end

    context 'when file is hidden' do
      let(:attached_file) { create(:attached_file, :with_file, work: work, hide: true) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(access: 'dark', download: 'none') }
    end
  end
end
