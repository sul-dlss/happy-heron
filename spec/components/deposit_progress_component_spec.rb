# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositProgressComponent do
  it 'renders the component' do
    expect(render_inline(described_class.new).to_html)
      .to include('1. File')
  end
end
