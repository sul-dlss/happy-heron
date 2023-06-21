# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contributor do
  subject(:contributor) { build(:person_contributor) }

  it "has a first name" do
    expect(contributor.first_name).to be_present
  end

  it "has a last name" do
    expect(contributor.last_name).to be_present
  end

  describe "#role_term=" do
    it "assigns both role and contributor_type" do
      contributor.role_term = "organization|Contributing author"
      expect(contributor.contributor_type).to eq "organization"
      expect(contributor.role).to eq "Contributing author"
    end
  end

  describe "#role_term" do
    it "reads both role and contributor_type" do
      expect(contributor.role_term).to eq "person|Contributing author"
    end
  end

  describe "#valid?" do
    context "when the role is Department" do
      subject { build(:org_contributor, role: "Department") }

      it { is_expected.to be_valid }
    end
  end
end
