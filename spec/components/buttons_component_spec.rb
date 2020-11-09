# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonsComponent do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder, submit: nil) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('<div class="row justify-content-end">')
  end
end
