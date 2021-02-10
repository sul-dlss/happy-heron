# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkTypeValidator do
  let(:record) { WorkForm.new(work: Work.new, work_version: WorkVersion.new) }
  let(:validator) { described_class.new({ attributes: ['stub'] }) }

  before do
    validator.validate_each(record, :work_type, value)
  end

  WorkType.type_list.each do |work_type_id|
    context "with a valid type (#{work_type_id.inspect})" do
      let(:value) { work_type_id }

      it 'validates' do
        expect(record.errors).to be_empty
      end
    end
  end

  ['map', '', nil].each do |work_type_id|
    context "with an invalid type (#{work_type_id.inspect})" do
      let(:value) { work_type_id }

      it 'fails to validate' do
        expect(record.errors.full_messages.first).to eq('Work type is not a valid work type')
      end
    end
  end
end
