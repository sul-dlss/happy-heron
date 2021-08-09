# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ButtonsComponent do
  let(:component) { described_class.new(form: form) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build_stubbed(:work, collection: build(:collection, id: 7)) }
  let(:work_version) { build(:work_version, work: work) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  context 'when collection does not require reviews' do
    it 'renders submit button as "Deposit"' do
      expect(rendered.css('input[value="Deposit"]')).to be_present
    end
  end

  context 'when collection requires reviews' do
    let(:work) { build_stubbed(:work, collection: build(:collection, :with_reviewers, id: 8)) }

    it 'renders submit button as "Submit for approval"' do
      expect(rendered.css('input[value="Submit for approval"]')).to be_present
    end
  end

  it 'renders the save draft button' do
    expect(rendered.css('input[value="Save as draft"]')).to be_present
  end
end
