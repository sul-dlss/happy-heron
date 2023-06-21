# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::AddFilesComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { build(:work) }
  let(:work_version) { build(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  context "with an unpersisted file component" do
    it "renders the component" do
      expect(rendered.to_html).to include("Add your files")
      expect(rendered.css("button.dz-clickable").to_html).to include("Choose files")
    end
  end

  context "with a persisted file component" do
    let(:attached_file) { create(:attached_file, :with_file) }
    let(:work_version) { build(:work_version, attached_files: [attached_file]) }

    it "renders the component with the filename visible" do
      expect(rendered.to_html).to include("Modify your files")
      expect(rendered.to_html).to include(attached_file.filename.to_s)
      expect(rendered.css("button.dz-clickable").to_html).to include("Choose files")
    end
  end

  context "when globus section" do
    it "shows the globus upload option" do
      expect(rendered.to_html).to include("Set up a Stanford Globus account")
      expect(rendered.to_html).not_to include("Check this box once all your files have been uploaded to Globus.")
    end
  end

  context "when creating a new work version from a previous globus upload version" do
    let(:work_version) { build(:work_version, :with_globus_endpoint, work:) }
    let(:work_form) { WorkForm.new(work_version:, work:) }

    it "does not shows the globus files confirmation checkbox" do
      expect(rendered.to_html).not_to include("Check this box once all your files have completed uploading to Globus.")
    end
  end
end
