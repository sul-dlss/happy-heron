# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Print terms of deposit' do
  it 'renders the terms of deposit' do
    visit print_terms_of_deposit_path
    expect(page).to have_content('Terms of Deposit')
  end
end
