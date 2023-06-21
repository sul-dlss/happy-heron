# frozen_string_literal: true

require "rails_helper"

RSpec.describe ContactEmail do
  subject(:contact_email) { build(:contact_email, emailable: work) }

  let(:work) { build(:work) }

  it "has an email" do
    expect(contact_email.email).to be_present
  end

  it "belongs to a work" do
    expect(contact_email.emailable).to eq work
  end
end
