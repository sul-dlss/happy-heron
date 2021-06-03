# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DraftWorkForm do
  subject(:form) { described_class.new(work_version: work_version, work: work) }

  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }

  describe 'param_key' do
    it 'is the same as work' do
      expect(form.model_name.param_key).to eq 'work'
    end
  end
end
