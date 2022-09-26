# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DraftWorkForm do
  subject(:form) { described_class.new(work_version:, work:) }

  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }

  describe 'param_key' do
    it 'is the same as work' do
      expect(form.model_name.param_key).to eq 'work'
    end
  end

  describe 'type validation' do
    let(:errors) { form.errors.where(:work_type) }
    let(:messages) { errors.map(&:message) }

    it 'does not validate with an invalid work type' do
      form.validate(work_type: 'a pile of something')
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid work type']
    end

    it 'does not validate with a missing work type' do
      form.validate(work_type: '')
      expect(form).not_to be_valid
      expect(messages).to eq ['can\'t be blank', 'is not a valid work type']
    end
  end

  describe 'subtype validation' do
    let(:errors) { form.errors.where(:subtype) }
    let(:messages) { errors.map(&:message) }

    it 'validates with a valid work_type and a "more" type' do
      form.validate(work_type: 'data', subtype: ['Animation'])
      expect(messages).to be_empty
    end

    it 'does not validate with a work_type that requires a user-supplied subtype and is empty' do
      form.validate(work_type: 'other', subtype: [])
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid subtype for work type other']
    end

    it 'validates with a valid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Documentation'])
      expect(messages).to be_empty
    end
  end

  describe '#dedupe_keywords' do
    context 'when there are no duplicate keywords' do
      let(:work_version) { create(:work_version, :with_keywords) }

      it 'does not remove any keywords' do
        expect(work_version.keywords.size).to eq 3
        form.dedupe_keywords
        expect(work_version.keywords.reload.size).to eq 3
      end
    end

    context 'when there is one exact duplicate keyword' do
      let(:work_version) { create(:work_version, :with_duped_keywords) }

      it 'removes duplicate keyword' do
        expect(work_version.keywords.size).to eq 2
        form.dedupe_keywords
        expect(work_version.keywords.reload.size).to eq 1
      end
    end

    context 'when there are duplicate keywords with same label but one has a blank uri' do
      let(:work_version) { create(:work_version, :with_duped_keywords, keywords_count: 3) }

      before { work_version.keywords.first.update(uri: '') }

      it 'removes duplicate keywords without uri' do
        expect(work_version.keywords.size).to eq 3
        form.dedupe_keywords
        expect(work_version.keywords.reload.size).to eq 1
        expect(work_version.keywords.first.uri).not_to be_empty # the keyword that is left is the one with the URI
      end
    end

    context 'when there are some duplicate keywords and some unique keywords' do
      let(:work_version) { create(:work_version, :with_keywords) }
      let(:keyword) { create(:keyword, :fixed_value, work_version:) }

      before { work_version.keywords << [keyword, keyword, keyword] }

      it 'removes just the duplicate keywords' do
        expect(work_version.keywords.size).to eq 6
        form.dedupe_keywords
        expect(work_version.keywords.reload.size).to eq 4
      end
    end
  end
end
