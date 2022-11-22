# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::FormComponent do
  let(:component) { described_class.new(work_form:) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build_stubbed(:collection, :depositor_selects_access, id: 7) }
  let(:work) { build_stubbed(:work, collection:) }
  let(:work_version) { build_stubbed(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(component) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Deposit', 'Save as draft', 'Add your files',
                  'Title of deposit and contact information',
                  'List authors and contributors',
                  'Enter dates related to your deposit',
                  'Describe your deposit',
                  'Settings for release date and download access',
                  'Select a license')
    expect(rendered.to_html)
      .not_to include("What's changing?")
  end

  context 'when globus feature enabled' do
    before do
      allow(Settings).to receive(:globus_upload).and_return true
    end

    it 'uses the deposit-button controller' do
      expect(rendered.to_html).to include('auto-citation unsaved-changes deposit-button')
    end
  end

  context 'when globus feature is not enabled' do
    before do
      allow(Settings).to receive(:globus_upload).and_return false
    end

    it 'does not use the deposit-button controller' do
      expect(rendered.to_html).not_to include('auto-citation unsaved-changes deposit-button')
    end
  end
end
