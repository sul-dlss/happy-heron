# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileGenerator do
  let(:model) { described_class.generate(work_version: work_version, attached_file: attached_file) }
  let(:work_version) { build(:work_version) }

  describe '#access' do
    subject { model.access }

    context 'when file is visible' do
      let(:attached_file) { create(:attached_file, :with_file, work_version: work_version) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(access: 'world', download: 'world') }
    end

    context 'when file is hidden' do
      let(:attached_file) { create(:attached_file, :with_file, work_version: work_version, hide: true) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(access: 'dark', download: 'none') }
    end
  end
end
