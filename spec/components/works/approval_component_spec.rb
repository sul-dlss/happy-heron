# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::ApprovalComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { build_stubbed(:work_version) }

  context "when not needing approval" do
    before do
      allow(controller).to receive(:allowed_to?).and_return(false)
    end

    it "renders nothing" do
      expect(rendered.to_html).to be_blank
    end
  end

  context "when needing approval" do
    before do
      allow(controller).to receive(:allowed_to?).and_return(true)
    end

    it "renders the widget" do
      expect(rendered.css("header").to_html).to include(
        "Review all details below, then approve or return this deposit"
      )
    end
  end
end
