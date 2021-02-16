# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::DepositProgressComponent, type: :component do
  let(:component) { described_class.new(work_version: work_version) }
  let(:work) { build_stubbed(:work, collection: build(:collection, :with_contact_emails, id: 7)) }
  let(:work_version) { build_stubbed(:work_version, work: work) }
  let(:rendered) { render_inline(component) }

  context 'when work is new' do
    let(:work) { build(:work) }

    it 'only license and release are marked as active' do
      expect(rendered.css('li.active').size).to eq 2
    end
  end

  context 'when work has a title' do
    let(:work_version) { build_stubbed(:work_version, :with_contact_emails, work: work) }

    it 'marks some steps as active' do
      expect(rendered.css('li.active').size).to eq 3
    end
  end

  context 'when work has everything' do
    let(:work_version) do
      build_stubbed(:valid_work_version, agree_to_terms: true, attached_files: [build_stubbed(:attached_file)])
    end

    it 'marks all steps as active' do
      expect(rendered.css('li.active').size).to eq 7
    end
  end

  describe '#has_description?' do
    subject { component.has_description? }

    context 'without keywords' do
      let(:work_version) { build_stubbed(:work_version) }

      it { is_expected.to be false }
    end

    context 'with keywords' do
      let(:work_version) { build_stubbed(:work_version, :with_keywords) }

      it { is_expected.to be true }
    end

    context 'with music and no subtypes' do
      let(:work_version) { build_stubbed(:work_version, :with_keywords, work_type: WorkType::MUSIC, subtype: []) }

      it { is_expected.to be false }
    end

    context 'with music and a subtype' do
      let(:work_version) do
        build_stubbed(:work_version, :with_keywords, work_type: WorkType::MUSIC, subtype: %w[Sound])
      end

      it { is_expected.to be true }
    end

    context 'with mixed material and one subtypes' do
      let(:work_version) do
        build_stubbed(:work_version, :with_keywords, work_type: WorkType::MIXED_MATERIAL, subtype: %w[Data])
      end

      it { is_expected.to be false }
    end

    context 'with mixed material and two subtypes' do
      let(:work_version) do
        build_stubbed(:work_version, :with_keywords, work_type: WorkType::MIXED_MATERIAL, subtype: %w[Data Image])
      end

      it { is_expected.to be true }
    end

    context 'with other and no subtypes' do
      let(:work_version) { build_stubbed(:work_version, :with_keywords, work_type: WorkType::OTHER, subtype: []) }

      it { is_expected.to be false }
    end

    context 'with other and a subtype' do
      let(:work_version) do
        build_stubbed(:work_version, :with_keywords, work_type: WorkType::OTHER, subtype: %w[Sound])
      end

      it { is_expected.to be true }
    end
  end
end
