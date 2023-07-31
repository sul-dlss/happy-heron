# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collections::EditTermsOfUseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(form:)) }

  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version, collection:) }

  let(:collection_form) { CreateCollectionForm.new(collection:, collection_version:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }

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
end
