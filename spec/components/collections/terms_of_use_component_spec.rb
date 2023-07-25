# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collections::TermsOfUseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(collection:)).to_html }

  let(:collection_version) { build_stubbed(:collection_version) }

  context "with a collection that has a required license" do
    let(:collection) do
      build_stubbed(:collection, :with_required_license, required_license:,
        head: collection_version)
    end
    let(:required_license) { "MIT" }

    it { is_expected.to include(required_license) }
    it { is_expected.to include("Required license") }
  end

  context "with a collection that has a default license" do
    let(:collection) do
      build_stubbed(:collection, default_license:, head: collection_version)
    end
    let(:default_license) { "Apache-2.0" }

    it { is_expected.to include(default_license) }
    it { is_expected.to include("Default license (depositor selects)") }
  end

  describe "custom rights settings display" do
    context "when custom rights are not enabled for the collection" do
      let(:collection) { build_stubbed(:collection, allow_custom_rights_statement: false) }

      it { is_expected.to include("Additional terms of use are disabled for this collection") }
    end

    context "when a pre-determined custom right statement is provided by the collection" do
      let(:collection) { build_stubbed(:collection, :with_custom_rights_from_collection) }

      it { is_expected.to include("\"#{collection.provided_custom_rights_statement}\"") }
    end

    context "when the user is able to enter their own custom rights statement" do
      let(:expected_custom_rights_info) do
        "The depositor is allowed to enter their own terms. They will be presented with the following instructions: \"#{effective_instructions}\""
      end

      context "when instructions for the depositor's custom rights statement are specified by the collection" do
        let(:collection) { build_stubbed(:collection, :with_custom_rights_instructions_from_collection) }
        let(:effective_instructions) { collection.custom_rights_statement_custom_instructions }

        it { is_expected.to include(expected_custom_rights_info) }
      end

      context "when the default H2 instructions for depositors entering custom rights should be displayed to the depositor" do
        let(:collection) { build_stubbed(:collection, :with_custom_rights_from_depositor) }
        let(:effective_instructions) { Settings.access.default_instructions_for_custom_use_statement }

        it { is_expected.to include(expected_custom_rights_info) }
      end
    end
  end
end
