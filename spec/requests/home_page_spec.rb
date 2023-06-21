# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Homepage requests" do
  context "with unauthenticated user" do
    before do
      sign_out
    end

    it 'has title of "SDR | Stanford Digital Repository"' do
      get "/"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>SDR | Stanford Digital Repository</title>")
    end
  end

  context "with authenticated user" do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'has title of "SDR | Stanford Digital Repository"' do
      get "/"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<title>SDR | Stanford Digital Repository</title>")
    end
  end
end
