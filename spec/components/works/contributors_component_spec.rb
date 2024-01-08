# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorsComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, vc_test_controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(described_class.new(form:)) }

  it 'renders the component' do
    expect(rendered.to_html).to include 'Additional contributors'
  end

  context 'with an existing organizational contributor' do
    let(:work_version) { build(:work_version, contributors: [build(:org_contributor)]) }

    it 'renders the component' do
      expect(rendered.css('option[@selected="selected"][@value="Sponsor"]')).to be_present
    end
  end
end
