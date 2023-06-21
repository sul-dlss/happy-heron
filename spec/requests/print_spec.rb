# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Print terms of deposit" do
  it "renders the terms of deposit" do
    get print_terms_of_deposit_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Terms of Deposit")
  end
end
