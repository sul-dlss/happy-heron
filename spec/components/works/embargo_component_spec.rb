# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder, label: nil, select: nil) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Manage release of this item for discovery and download after publication')
  end
end
