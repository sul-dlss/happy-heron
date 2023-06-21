# frozen_string_literal: true

require "rails_helper"

RSpec.describe PopoverComponent, type: :component do
  context "with an existing key" do
    let(:rendered) { render_inline(described_class.new(key: :what_type)) }

    it "renders the component" do
      expect(rendered.css("a").first["data-bs-content"]).to eq "Choose the one content type that best describes " \
                                                               "the overall or primary nature of the work. Click " \
                                                               "on each content type to view and select terms you " \
                                                               "may use to further describe the work you are " \
                                                               "depositing."
    end

    context "when tooltip contains html" do
      let(:rendered) { render_inline(described_class.new(key: "work.creation_date")) }

      it "renders the component" do
        expect(rendered.css("a").first["data-bs-content"]).to eq "Date or date range when the deposited work was " \
                                                                 "collected, generated, or created. <strong>" \
                                                                 "Unless you are depositing a dataset or content for " \
                                                                 "Stanford University Archives, please do not enter " \
                                                                 'a Creation Date</strong> The "Approximate" option ' \
                                                                 "should typically not be used with dates " \
                                                                 "containing a month and/or day."
      end
    end
  end

  context "with a non-existing key" do
    let(:rendered) { render_inline(described_class.new(key: :noop)) }

    it "renders nothing" do
      expect(rendered.to_html).to eq ""
    end
  end
end
