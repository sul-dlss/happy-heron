# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonsComponent do
  let(:component) { described_class.new(form: form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work, collection: build(:collection, id: 7)) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(depositable)
  end

  context 'when allowed to deposit' do
    let(:depositable) { true }

    it 'renders the deposit button' do
      expect(rendered.css('input[value="Deposit"]')).to be_present
    end
  end

  context 'when not allowed to deposit' do
    let(:depositable) { false }

    it "doesn't render the deposit button" do
      expect(rendered.css('input[value="Deposit"]')).not_to be_present
    end
  end
end
