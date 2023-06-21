# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Download a zip file of all attached files" do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { create(:work_version, work:) }
  let(:user) { create(:user) }
  let(:work) { create(:work, owner: user) }
  let(:work_id) { work.id }

  context "with unauthenticated user" do
    before do
      sign_out
    end

    it "redirects from /works/:work_id/zip to login URL" do
      get "/works/#{work_id}/zip"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "with an attached file" do
    before do
      sign_in user
      work.update(head: work_version)
      create(:attached_file, :with_file, work_version:)
    end

    it "streams the attachment" do
      get "/works/#{work_id}/zip"
      expect(response.headers["Content-Length"]).to eq "7892"
    end
  end

  context "with no files" do
    before do
      sign_in user
      work.update(head: work_version)
    end

    it "does a not found error" do
      expect { get "/works/#{work_id}/zip" }.to raise_error ActionController::RoutingError
    end
  end
end
