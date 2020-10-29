# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Keyword, type: :model do
  subject(:keyword) { build(:keyword, work: work) }

  let(:work) { build(:work) }

  it 'has a label' do
    expect(keyword.label).to be_present
  end

  it 'has a url' do
    expect(keyword.uri).to be_present
  end

  it 'belongs to a work' do
    expect(keyword.work).to be_a(Work)
  end
end
