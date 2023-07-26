# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::FormComponent do
  let(:component) { described_class.new(work_form:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build_stubbed(:work, collection:) }
  let(:work_version) { build_stubbed(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  context 'when the collection does not allow a custom rights statement' do
    let(:collection) { build_stubbed(:collection, :depositor_selects_access, id: 7) }

    it "renders the component" do
      expect(rendered.to_html)
        .to include("Deposit", "Save as draft", "Add your files",
          "Title of deposit and contact information",
          "List authors and contributors",
          "Enter dates related to your deposit",
          "Describe your deposit",
          "Settings for release date and download access",
          "License",
          "auto-citation unsaved-changes deposit-button")
      expect(rendered.to_html)
        .not_to include("What's changing?")
      expect(rendered.to_html)
        .not_to include("Additional terms of use")
      end
  end

  context 'when the collection allows a custom rights statement' do
    let(:collection) { build_stubbed(:collection, :depositor_selects_access, :with_custom_rights_from_depositor, id: 7) }

    it "renders the component" do
      expect(rendered.to_html)
        .to include("Deposit", "Save as draft", "Add your files",
          "Title of deposit and contact information",
          "List authors and contributors",
          "Enter dates related to your deposit",
          "Describe your deposit",
          "Settings for release date and download access",
          "License",
          "Additional terms of use",
          "auto-citation unsaved-changes deposit-button")
      expect(rendered.to_html)
        .not_to include("What's changing?")
    end
  end

  context 'when the collection provides a custom rights statement' do
    let(:collection) { build_stubbed(:collection, :depositor_selects_access, :with_custom_rights_from_collection, id: 7) }

    it "renders the component" do
      expect(rendered.to_html)
        .to include("Deposit", "Save as draft", "Add your files",
          "Title of deposit and contact information",
          "List authors and contributors",
          "Enter dates related to your deposit",
          "Describe your deposit",
          "Settings for release date and download access",
          "License",
          "Additional terms of use",
          "An addendum to the built in terms of use",
          "auto-citation unsaved-changes deposit-button")
      expect(rendered.to_html)
        .not_to include("What's changing?")
    end
  end
end
