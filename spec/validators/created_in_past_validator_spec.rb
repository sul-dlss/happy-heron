# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreatedInPastValidator do
  let(:options) { { attributes: ['hi'] } }
  let(:validator) { described_class.new(options) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:record) { WorkForm.new(work_version: work_version, work: work) }

  before do
    validator.validate_each(record, attribute, value)
  end

  context 'when there is a single date' do
    let(:attribute) { :created_edtf }
    let(:value) { EDTF.parse('1800-01-01') }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end

    context 'with a date prior to 1000' do
      let(:attribute) { :created_edtf }
      let(:value) { EDTF.parse('0800-01-01') }

      it 'has errors' do
        expect(record.errors.full_messages).to eq ['Created edtf must have a four digit year']
      end
    end

    describe 'validate date is in the past' do
      let(:attribute) { :created_edtf }
      let(:today) { Time.zone.today }

      context 'with a date after the current year' do
        let(:year) { today.year + 1 }
        let(:value) { EDTF.parse(year.to_s) }

        it 'has errors' do
          expect(record.errors.full_messages).to eq ['Created edtf must be in the past']
        end
      end

      context 'with a date after the current month' do
        let(:next_month) { 1.month.from_now }
        let(:year) { next_month.year }
        let(:month) { next_month.month }

        let(:value) { EDTF.parse(format('%<year>d-%<month>02d', year: year, month: month)) }

        it 'has errors' do
          expect(record.errors.full_messages).to eq ['Created edtf must be in the past']
        end
      end

      context 'with a date after the current day' do
        let(:tomorrow) { 1.day.from_now }
        let(:year) { tomorrow.year }
        let(:month) { tomorrow.month }
        let(:day) { tomorrow.day }

        let(:value) { EDTF.parse(format('%<year>d-%<month>02d-%<day>02d', year: year, month: month, day: day)) }

        it 'has errors' do
          expect(record.errors.full_messages).to eq ['Created edtf must be in the past']
        end
      end
    end
  end

  context 'when there is a date range' do
    let(:attribute) { :created_edtf }
    let(:value) { EDTF.parse('1800-01-01/1900-01-01') }

    it 'has no errors' do
      expect(record.errors).to be_empty
    end

    context 'with a start date prior to 1000' do
      let(:attribute) { :created_edtf }
      let(:value) { EDTF.parse('0800-01-01/1900-01-01') }

      it 'has errors' do
        expect(record.errors.full_messages).to eq ['Created edtf start must have a four digit year']
      end
    end

    context 'with a start date after the current year' do
      let(:attribute) { :created_edtf }
      let(:year) { Time.zone.today.year + 1 }
      let(:value) { EDTF.parse("#{year}-01-01/2200-01-01") }

      it 'has errors' do
        expect(record.errors.full_messages).to eq ['Created edtf start must be in the past',
                                                   'Created edtf end must be in the past']
      end
    end

    context 'with dates out of order' do
      let(:attribute) { :created_edtf }
      let(:value) { EDTF.parse('2000-01-01/1900-01-01') }

      it 'has errors' do
        expect(record.errors.full_messages).to eq ['Created date range start must be before end']
      end
    end
  end
end
