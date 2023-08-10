# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collections::EditTermsOfUseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(form:)) }

  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version, collection:) }

  let(:collection_form) { CreateCollectionForm.new(collection:, collection_version:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }

  before do
    collection_form.prepopulate!
  end

  context "with custom rights for the collection disallowed" do
    let(:collection) { build(:collection, allow_custom_rights_statement: false) }

    it "selects the 'No' option" do
      expect(rendered.css("input#custom_rights_statement_option_none[checked]").size).to eq 1
    end
  end

  context "with custom rights for the collection allowed" do
    context "with custom rights provided by the collection" do
      let(:collection) { build(:collection, :with_custom_rights_from_collection) }

      it "selects the 'Yes, include the following' option" do
        expect(rendered.css("input#custom_rights_statement_option_custom[checked]").size).to eq 1
      end

      it "displays the saved terms from the Collection object" do
        expect(rendered.to_html).to match(/<textarea .*name="provided_custom_rights_statement".*\n#{collection.provided_custom_rights_statement}/m)
      end
    end

    context "with custom rights entered by the depositor" do
      let(:collection) { build(:collection, :with_custom_rights_from_depositor) }

      it "selects the 'Yes, allow depositor' option" do
        expect(rendered.css("input#custom_rights_statement_option_entered_by_depositor[checked]").size).to eq 1
      end

      context "with custom instructions set on the collection" do
        let(:collection) { build(:collection, :with_custom_rights_instructions_from_collection) }

        it "displays the saved instructions from the Collection object" do
          expect(rendered.to_html).to match(/<textarea .*name="custom_rights_statement_custom_instructions".*\n#{collection.custom_rights_statement_custom_instructions}/m)
        end
      end
    end
  end
end
