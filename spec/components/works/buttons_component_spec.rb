# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ButtonsComponent, type: :component do
  let(:component) { described_class.new(form:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(component) }

  before do
    allow(vc_test_controller).to receive(:allowed_to?).and_return(true)
  end

  context 'when work is not persisted' do
    let(:work) { build(:work, collection: build(:collection, id: 7)) }
    let(:work_version) { build(:work_version, work:, state: 'new') }

    it 'renders cancel button with target location as work show page' do
      expect(rendered.css('a[text()="Cancel"]')).to be_present
      expect(rendered.css("a[href='/collections/7/works']")).to be_present
    end
  end

  context 'when work is persisted' do
    let(:work) { build_stubbed(:work, collection: build(:collection, id: 7)) }
    let(:work_version) { build(:work_version, work:) }

    it 'renders cancel button with target location as work show page' do
      expect(rendered.css('a[text()="Cancel"]')).to be_present
      expect(rendered.css("a[href='/works/#{work.id}']")).to be_present
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

  context 'when globus' do
    let(:work) { build(:work, collection: build(:collection, id: 7)) }
    let(:work_version) { build(:work_version, work:, state: 'new') }

    it 'updates the deposit button' do
      expect(rendered.css('input[value="Deposit"]')).to be_present
      expect(rendered.css('input[value="Deposit"][attribute="disabled"]')).not_to be_present
      expect(rendered.to_html).to include('data-deposit-button-target="depositButton"')
    end
  end
end
