# frozen_string_literal: true

require "rails_helper"

RSpec.describe AbstractContributor do
  describe ".valid?" do
    context "when a person" do
      let(:contributor) { build(:person_contributor, orcid:) }

      context "when valid ORCID" do
        let(:orcid) { "https://orcid.org/0000-0003-1527-0030" }

        it "is valid" do
          expect(contributor.valid?).to be true
        end
      end

      context "when invalid ORCID" do
        let(:orcid) { "https://orcid.org/0000-0003-1527-0030z" }

        it "is invalid" do
          expect(contributor.valid?).to be false
        end
      end

      context "when no ORCID" do
        let(:orcid) { nil }

        it "is valid" do
          expect(contributor.valid?).to be true
        end
      end
    end

    context "when an organization" do
      let(:contributor) { build(:org_contributor, orcid:) }

      context "when ORCID" do
        let(:orcid) { "https://orcid.org/0000-0003-1527-0030" }

        it "is invalid" do
          expect(contributor.valid?).to be false
        end
      end

      context "when no ORCID" do
        let(:orcid) { nil }

        it "is valid" do
          expect(contributor.valid?).to be true
        end
      end
    end
  end
end
