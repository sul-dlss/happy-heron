# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbargoDateValidator do
  let(:options) { { attributes: ['hi'] } }
  let(:validator) { described_class.new(options) }
  let(:record) { WorkForm.new(Work.new) }

  before do
    validator.validate_each(record, attribute, value)
  end

  context 'when no date is provided' do
    let(:attribute) { :embargo_date }
    # let(:value) { Time.zone.today + 2.years }
    let(:value) { nil }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'with a date 2 years in the future' do
    let(:attribute) { :embargo_date }
    let(:value) { Time.zone.today + 2.years }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'with a date more than 3 years in the future' do
    let(:attribute) { :embargo_date }
    let(:value) { Time.zone.today + 3.years + 1.day }

    it 'has errors' do
      expect(record.errors.full_messages).to eq ['Embargo date Must be less than 3 years in the future']
    end
  end
end
