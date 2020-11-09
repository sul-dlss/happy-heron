# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::AgreementComponent do
  let(:form) { instance_double(ActionView::Helpers::FormBuilder, check_box: nil, label: nil) }

  it 'renders the component' do
    expect(render_inline(described_class.new(form: form)).to_html)
      .to include('Terms of Deposit')
  end
end
