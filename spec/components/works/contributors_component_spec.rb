# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorsComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { build(:work) }
  let(:work_form) { WorkForm.new(work) }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.to_html).to include 'Additional contributors (optional)'
  end

  context 'with an existing organizational contributor' do
    let(:work) { build(:work, contributors: [build(:org_contributor)]) }

    it 'renders the component' do
      expect(rendered.css('option[@selected="selected"][@value="organization|Sponsor"]')).to be_present
    end
  end
end
