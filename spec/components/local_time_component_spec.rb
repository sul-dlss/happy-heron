# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocalTimeComponent, type: :component do
  let(:rendered) do
    render_inline(described_class.new(datetime: 1.day.ago))
  end

  it 'renders custom element' do
    expect(rendered.css('relative-time')).to be_present
  end
end
