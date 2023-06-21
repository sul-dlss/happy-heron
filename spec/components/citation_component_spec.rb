# frozen_string_literal: true

require "rails_helper"

RSpec.describe CitationComponent, type: :component do
  subject(:button) { rendered.css("button").first }

  let(:rendered) { render_inline(described_class.new(work_version:)) }

  context "when the state is deposited" do
    let(:work_version) { build(:work_version, :deposited) }

    it "renders a button" do
      expect(button["data-bs-target"]).to eq "#citationModal"
      expect(button["data-controller"]).to eq "show-citation"
      expect(button["disabled"]).not_to be_present
    end
  end

  context "when the state is purl_reserved" do
    let(:work_version) { build(:work_version, :purl_reserved) }

    it "renders a disabled button" do
      expect(button["disabled"]).to be_present
    end
  end

  context "when the state is first_draft" do
    let(:work_version) { build(:work_version, :first_draft) }

    it "renders a disabled button" do
      expect(button["disabled"]).to be_present
    end
  end
end
