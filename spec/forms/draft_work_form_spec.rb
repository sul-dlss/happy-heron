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
end
