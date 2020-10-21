# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorsComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, nil, controller.view_context, {}) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('List authors and contributors')
  end
end
