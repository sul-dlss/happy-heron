# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AgreementComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:rendered) { render_inline(described_class.new(form:)) }
  let(:work) { build(:work) }
  let(:work_version) { build(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('SDR Terms of Deposit')
    expect(rendered.css('h2').text).to eq 'Terms of Deposit *'
  end
end
