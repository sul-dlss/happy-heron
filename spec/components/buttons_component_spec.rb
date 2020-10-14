# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonsComponent do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder, submit: nil) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('<div class="col-md-3 ml-md-auto">')
  end
end
