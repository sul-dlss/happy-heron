# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachedFile, type: :model do
  subject(:attached_file) { build(:attached_file, :with_file) }

  it 'has a label' do
    expect(attached_file.label).to be_present
  end

  it 'has a hide bit' do
    expect(attached_file).not_to be_hide
  end

  it 'has attached files' do
    expect(attached_file.file).to be_attached
  end
end
