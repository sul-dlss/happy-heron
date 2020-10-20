# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard requests' do
  it 'shows links to create in a collection' do
    get '/dashboard'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include 'Your collections'
  end
end
