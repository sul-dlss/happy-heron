# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::WorkTypeModalComponent, type: :component do
  it 'renders the component' do
    expect(render_inline(described_class.new).to_html)
      .to include('What type of content will you deposit?')
  end
end
