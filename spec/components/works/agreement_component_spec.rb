# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::AgreementComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { build(:work) }
  let(:work_version) { build(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  it "renders the component" do
    expect(rendered.to_html)
      .to include("SDR Terms of Deposit")
    expect(rendered.css("header").text).to eq "Terms of Deposit *"
  end
end
