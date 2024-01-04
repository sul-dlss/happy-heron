# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbargoDateValidator do
  let(:options) { { attributes: ['hi'] } }
  let(:validator) { described_class.new(options) }
  let(:collection) { create(:collection, release_option: 'depositor-selects', release_duration: '3 years') }
  let(:work) { create(:work, collection:) }
  let(:current_date) { Time.now.in_time_zone('Pacific Time (US & Canada)').to_date }
  let(:work_version) { create(:work_version, work:) }
  let(:record) { WorkForm.new(work_version:, work:) }

  before do
    validator.validate_each(record, attribute, value)
  end

  context 'when no date is provided' do
    let(:attribute) { :embargo_date }
    let(:value) { nil }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'with a date in the past' do
    let(:attribute) { :embargo_date }
    let(:value) { current_date - 2.days }

    it 'has errors' do
      expect(record.errors.full_messages).to eq ['Embargo date must be in the future']
    end
  end

  context 'with a date of tomorrow' do
    let(:attribute) { :embargo_date }
    let(:value) { current_date + 1.day }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'with a date 2 years in the future' do
    let(:attribute) { :embargo_date }
    let(:value) { current_date + 2.years }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'with a date more than 3 years in the future' do
    let(:attribute) { :embargo_date }
    let(:value) { current_date + 3.years + 1.day }

    it 'has errors' do
      expect(record.errors.full_messages).to eq ['Embargo date must be less than 3 years in the future']
    end
  end

  context 'with a date more than the collection release_duration' do
    let(:collection) { create(:collection, release_option: 'depositor-selects', release_duration: '1 year') }
    let(:attribute) { :embargo_date }
    let(:value) { current_date + 2.years }

    it 'has errors' do
      expect(record.errors.full_messages).to eq ['Embargo date must be less than 1 year in the future']
    end
  end
end
