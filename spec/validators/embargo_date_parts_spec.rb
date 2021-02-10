# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbargoDateParts do
  let(:validator) { described_class.new }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:record) { WorkForm.new(work_version: work_version, work: work) }

  context 'when a valid date is provided' do
    before do
      record.embargo_date = Date.new
      validator.validate(record)
    end

    it 'does not have errors' do
      expect(record.errors).to be_empty
    end
  end

  context 'when month or day is not provided' do
    before do
      record.release = 'embargo'
      validator.validate(record)
    end

    it 'has errors' do
      expect(record.errors.full_messages).to eq ['Embargo-date Must provide all parts']
    end
  end
end
