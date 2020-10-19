# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Home Page', type: :request do
  it 'html title is "SDR | Stanford Digital Repository"' do
    get '/'
    expect(response).to be_successful
    expect(response.body).to match '<head>\s*<title>SDR | Stanford Digital Repository</title>\s*</head>'
  end
end
