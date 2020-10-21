# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorsComponent do
  it 'renders the component' do
    expect(render_inline(described_class.new).to_html)
      .to include('Authors and contributors')
  end
end
