# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::SelectedKeywordComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, keyword, controller.view_context, {}) }
  let(:keyword) { build(:keyword, label: 'computers') }
  let(:rendered) { render_inline(described_class.new(form: form)) }

  it 'renders the component' do
    expect(rendered.css('.btn.remove').to_html)
      .to include '×'
    expect(rendered.css('.choice-display').to_html)
      .to include 'computers'
  end
end
