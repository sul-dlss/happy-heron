# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkTypeComponent do
  let(:form) do
    instance_double(ActionView::Helpers::FormBuilder,
                    object: work,
                    label: nil,
                    select: nil,
                    hidden_field: nil)
  end
  let(:work) { create(:work) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Type of Book deposit')
  end
end
