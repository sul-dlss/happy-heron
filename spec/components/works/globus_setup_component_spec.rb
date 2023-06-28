# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::GlobusSetupComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { build_stubbed(:work_version, state: "first_draft", upload_type: "globus", globus_endpoint: "user/123/version1") }

  context "when the globus user is valid" do
    before do
      allow(GlobusClient).to receive(:user_valid?).and_return(true)
    end

    it "renders the instructions" do
      expect(rendered.to_html).to include "How to complete your deposit using Globus"
      expect(rendered.css("a").map { |node| node["href"] }).to include "https://app.globus.org/file-manager?&origin_id=endpoint_uuid&origin_path=/uploads/user/123/version1"
    end
  end

  context "when the globus user is not valid" do
    before do
      allow(GlobusClient).to receive(:user_valid?).and_return(false)
    end

    it "renders a message about the user" do
      expect(rendered.to_html).to include "Globus account associated with your stanford.edu email is not valid"
    end
  end
end
