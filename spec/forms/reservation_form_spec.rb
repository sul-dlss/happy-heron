# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReservationForm do
  subject(:form) { described_class.new(work_version: work_version, work: work) }

  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }

  describe 'title validation' do
    before do
      form.validate(title: title)
    end

    context 'with an blank title' do
      let(:title) { '' }

      it { is_expected.not_to be_valid }
    end

    context 'with a title' do
      let(:title) { 'something' }

      it { is_expected.to be_valid }
    end
  end
end
