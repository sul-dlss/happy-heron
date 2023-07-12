# frozen_string_literal: true

require "rails_helper"

RSpec.describe RelatedWork do
  subject(:related_work) { build(:related_work) }

  it "has a citation" do
    expect(related_work.citation).to be_present
  end

  context "when select attributes contain leading/trailing whitespace" do
    let(:related_work) do
      create(:related_work, citation: " The RTF file generated from the above, with scalable drawings ")
    end

    it "strips citation" do
      expect(related_work.citation).to eq("The RTF file generated from the above, with scalable drawings")
    end
  end
end
