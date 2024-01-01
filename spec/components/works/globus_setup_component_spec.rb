# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::GlobusSetupComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { build_stubbed(:work_version, state: "first_draft", upload_type: "globus", globus_endpoint: globus_endpoint, globus_origin:) }
  let(:globus_origin) { nil }
  let(:globus_endpoint) { "user/123/version1" }

  context "when the globus user is valid" do
    before do
      allow(GlobusClient).to receive(:user_valid?).and_return(true)
    end

    context "when no globus origin is set" do
      it "renders the instructions" do
        expect(rendered.to_html).to include "How to complete your deposit using Globus"
        expect(rendered.css("a").pluck("href")).to include "https://app.globus.org/file-manager?&destination_id=endpoint_uuid&destination_path=/uploads/user/123/version1"
      end
    end

    context "when globus origin is set" do
      let(:globus_origin) { "oak" }

      it "renders the instructions with origin_id in globus link" do
        expect(rendered.to_html).to include "How to complete your deposit using Globus"
        expect(rendered.css("a").pluck("href")).to include "https://app.globus.org/file-manager?&destination_id=endpoint_uuid&destination_path=/uploads/user/123/version1&origin_id=8b3a8b64-d4ab-4551-b37e-ca0092f769a7"
        expect(rendered.css("li span.placeholder").length).to be_zero
      end
    end

    context "when globus endpoint not yet set" do
      let(:globus_endpoint) { nil }

      it "renders the instructions with placeholders" do
        expect(rendered.to_html).to include "How to complete your deposit using Globus"
        expect(rendered.css("li span.placeholder").length).to be_positive
      end
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
