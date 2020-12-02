# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonsComponent do
  let(:component) { described_class.new(form: form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work, collection: build(:collection, id: 7)) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(component) }

  it 'renders the deposit button' do
    expect(rendered.css('input[value="Deposit"]')).to be_present
  end

  it 'renders the save draft button' do
    expect(rendered.css('input[value="Save as draft"]')).to be_present
  end
end
