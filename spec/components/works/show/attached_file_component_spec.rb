# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::Show::AttachedFileComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(attached_file:, depth: 1)) }
  let(:attached_file) { build(:attached_file, :with_file) }

  context "with an attached file" do
    it "shows a download link and the hide status" do
      expect(rendered.css("a").last["href"]).to start_with "/rails/active_storage/blobs/redirect/"
      expect(rendered.css("td").last.to_html).to include "No"
    end
  end

  context "with a published work that has an attached file" do
    let(:work_version) { create(:work_version, state: "deposited", attached_files: [attached_file]) }

    it "shows the share and download links" do
      expect(work_version.first_draft?).to be false
      expect(work_version.purl_reserved?).to be false
      expect(rendered.css("a")[-2]["href"]).to start_with "/preservation"
      expect(rendered.css("a").last["href"]).to start_with "https://stacks-test.stanford.edu/file"
    end
  end
end
