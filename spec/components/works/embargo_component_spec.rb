# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Manage release of this deposit for discovery and download after publication')
  end
end
