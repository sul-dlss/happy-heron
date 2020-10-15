# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoleTerm do
  subject(:role_term) { create(:role_term) }

  it 'has a label' do
    expect(role_term.label).to be_present
  end
end
