# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorRowComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }
  let(:component) { described_class.new(form: form) }
  let(:rendered) { render_inline(component) }

  it 'renders the hidden field and controls' do
    expect(rendered.css('input[name*="_destroy"]')).to be_present
    expect(rendered.css('button[aria-label="Remove"]')).to be_present
  end
end
