# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  subject(:form) { described_class.new(work) }

  let(:work) { build(:work) }

  describe 'populator on files' do
    it 'populates attached_files' do
      form.validate(attached_files: [{ 'label' => 'hello', 'hide' => true }])

      expect(form.attached_files.size).to eq 1
      expect(form.attached_files.first.label).to eq 'hello'
      expect(form.attached_files.first.hide).to be true
    end
  end
end
