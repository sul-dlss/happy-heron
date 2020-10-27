# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedWork do
  subject(:related_work) { build(:related_work) }

  it 'has a citation' do
    expect(related_work.citation).to be_present
  end

  it 'belongs to a work' do
    expect(related_work.work).to be_a(Work)
  end
end
