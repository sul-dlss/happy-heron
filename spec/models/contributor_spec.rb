# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor do
  subject(:contributor) { create(:contributor) }

  it 'has a first name' do
    expect(contributor.first_name).to be_present
  end

  it 'has a last name' do
    expect(contributor.last_name).to be_present
  end

  it 'belongs to a work' do
    expect(contributor.work).to be_a(Work)
  end

  it 'belongs to a role_term' do
    expect(contributor.role_term).to be_a(RoleTerm)
  end
end
