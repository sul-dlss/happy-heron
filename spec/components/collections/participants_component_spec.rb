# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collections::ParticipantsComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection:)) }

  context "when displaying a collection" do
    let(:depositors) { collection.depositors.map(&:sunetid).join(", ") }
    let(:managers) { collection.managed_by.map(&:sunetid).join(", ") }
    let(:collection) { build_stubbed(:collection, :with_managers, :with_depositors, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it "renders the participant component" do
      expect(rendered.css("table").to_html).to include(managers)
      expect(rendered.css("table").to_html).to include(depositors)
    end
  end
end
