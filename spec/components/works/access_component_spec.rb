# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AccessComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build(:collection, release_option: 'immediate') }
  let(:work) { build(:work, collection: collection) }
  let(:work_version) { build(:work_version, work: work) }
  let(:work_form) { WorkForm.new(work_version: work_version, work: work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  before do
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Who can download the files?')
  end

  context 'when collection access is depositor selects' do
    let(:work) { build(:work, collection: collection) }
    let(:collection) { build(:collection, :depositor_selects_access, release_option: 'immediate') }

    it 'renders the access selector' do
      expect(rendered.css('#access')).to be_present
    end
  end
end
