# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dashboard::CollectionHeaderComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version:)) }

  context "with a new, first draft collection" do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }
    let(:collection_id) { collection_version.collection.id }

    it "does not render the spinner" do
      expect(rendered.to_html).not_to include "fa-spinner"
    end

    it "has an edit button" do
      expect(rendered.css("turbo-frame").first["src"]).to eq "/collection_versions/#{collection_version.id}/edit_link"
    end
  end

  context "with a depositing collection" do
    let(:collection_version) { build_stubbed(:collection_version, :depositing) }

    it "does not render the spinner" do
      expect(rendered.to_html).to include "Depositing"
      expect(rendered.to_html).to include "fa-solid fa-spinner fa-pulse"
    end
  end
end
