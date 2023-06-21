# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::KeywordsRowComponent do
  subject(:rendered) { render_inline(described_class.new(form: form_builder)) }

  let(:work) { work_version.work }
  let(:work_version) { build_stubbed(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:keyword_form) do
    work_form.prepopulate!
    work_form.keywords.first
  end
  let(:form_builder) do
    ActionView::Helpers::FormBuilder.new("work", keyword_form, controller.view_context, {})
  end

  it "renders the component" do
    expect(rendered.to_html).to include("Keyword")
    expect(rendered.css(".plain-container")).to be_present
  end
end
