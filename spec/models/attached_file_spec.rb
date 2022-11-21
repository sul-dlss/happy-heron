# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttachedFile do
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

  it 'delegates to its blob' do
    expect(attached_file.filename).to eq(attached_file.file.attachment.blob.filename)
    expect(attached_file.content_type).to eq(attached_file.file.attachment.blob.content_type)
    expect(attached_file.byte_size).to eq(attached_file.file.attachment.blob.byte_size)
  end
end
