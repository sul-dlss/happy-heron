# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AccessComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work, collection: collection) }
  let(:collection) { build(:collection, release_option: 'immediate') }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Select which audience you would like to have access to download')
  end

  context 'when collection access is depositor selects' do
    let(:work) { build(:work) }

    before do
      work.collection.access = 'depositor-selects'
    end

    it 'renders the access selector' do
      expect(rendered.css('#access')).to be_present
    end
  end
end
