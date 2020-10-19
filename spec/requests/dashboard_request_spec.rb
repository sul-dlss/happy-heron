# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  before do
    create(:collection)
  end

  it 'shows links to create in a collection' do
    get '/dashboard'
    expect(response).to be_successful
    expect(response.body).to include 'Your collections'
  end
end
