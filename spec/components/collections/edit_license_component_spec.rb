# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collections::EditLicenseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(form:)) }

  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version, collection:) }

  let(:collection_form) { CreateCollectionForm.new(collection:, collection_version:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }

  context "with no license selected" do
    it "renders the prompt for the required license" do
      expect(rendered.to_html).to include("Select...")
    end
  end

  context "with a required license selected" do
    let(:collection) { build(:collection, required_license: "MIT") }

    it "selects the MIT license" do
      expect(rendered.to_html).to include('<option selected value="MIT">MIT License</option>')
    end
  end

  context "with a default license selected" do
    let(:collection) { build(:collection, default_license: "CC0-1.0") }

    it "selects the CC0 license" do
      expect(rendered.to_html).to include('<option selected value="CC0-1.0">CC0-1.0</option>')
    end
  end

  context "with custom rights for the collection disallowed" do
    let(:collection) { build(:collection, allow_custom_rights_statement: false) }

    it "selects the 'No' option for 'Include custom use statement'" do
      allow_custom_rights_statement_false_nodes = rendered.css("input#allow_custom_rights_statement_false")
      expect(allow_custom_rights_statement_false_nodes.size).to eq 1
      expect(allow_custom_rights_statement_false_nodes.first.attribute_nodes.find { |node| node.name == "checked" && node.value == "checked" }).to be_present
    end
  end

  context "with custom rights for the collection allowed" do
    let(:collection) { build(:collection, allow_custom_rights_statement: true) }

    it "selects the 'Yes' option for 'Include custom use statement'" do
      allow_custom_rights_statement_true_nodes = rendered.css("input#allow_custom_rights_statement_true")
      expect(allow_custom_rights_statement_true_nodes.size).to eq 1
      expect(allow_custom_rights_statement_true_nodes.first.attribute_nodes.find { |node| node.name == "checked" && node.value == "checked" }).to be_present
    end

    context "with custom rights provided by the collection" do
      let(:collection) { build(:collection, :with_custom_rights_from_collection) }

      it "selects the 'Provide specific terms' option" do
        custom_rights_statement_source_option_provided_by_collection_nodes = rendered.css("input#custom_rights_statement_source_option_provided_by_collection")
        expect(custom_rights_statement_source_option_provided_by_collection_nodes.size).to eq 1
        expect(custom_rights_statement_source_option_provided_by_collection_nodes.first.attribute_nodes.find { |node| node.name == "checked" && node.value == "checked" }).to be_present
      end

      it "displays the saved terms from the Collection object" do
        expect(rendered.to_html).to match(/<textarea .*name="provided_custom_rights_statement".*\n#{collection.provided_custom_rights_statement}/m)
      end
    end

    context "with custom rights entered by the depositor" do
      let(:collection) { build(:collection, :with_custom_rights_from_depositor) }

      it "selects the 'Allow depositor to enter their own terms' option" do
        custom_rights_statement_source_option_entered_by_depositor_nodes = rendered.css("input#custom_rights_statement_source_option_entered_by_depositor")
        expect(custom_rights_statement_source_option_entered_by_depositor_nodes.size).to eq 1
        expect(custom_rights_statement_source_option_entered_by_depositor_nodes.first.attribute_nodes.find { |node| node.name == "checked" && node.value == "checked" }).to be_present
      end

      context "with custom instructions set on the collection" do
        let(:collection) { build(:collection, :with_custom_rights_instructions_from_collection) }

        it "selects the 'No, display these instructions' option" do
          custom_rights_instructions_source_option_provided_by_collection_nodes = rendered.css("input#custom_rights_instructions_source_option_provided_by_collection")
          expect(custom_rights_instructions_source_option_provided_by_collection_nodes.size).to eq 1
          expect(custom_rights_instructions_source_option_provided_by_collection_nodes.first.attribute_nodes.find { |node| node.name == "checked" && node.value == "checked" }).to be_present
        end

        it "displays the saved instructions from the Collection object" do
          expect(rendered.to_html).to match(/<textarea .*name="custom_rights_statement_custom_instructions".*\n#{collection.custom_rights_statement_custom_instructions}/m)
        end
      end
    end
  end

  context "with errors" do
    let(:collection) { build(:collection, required_license: nil) }

    before do
      collection_form.errors.add(:license, "Either a required license or a default license must be present")
    end

    it "renders the message and adds invalid styles" do
      expect(rendered.css(".is-invalid ~ .invalid-feedback").text).to eq(
        "Either a required license or a default license must be present"
      )
      expect(rendered.css("#required_license.is-invalid")).to be_present
      expect(rendered.css("#default_license.is-invalid")).to be_present
    end
  end
end
