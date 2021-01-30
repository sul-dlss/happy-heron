# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::PurlReservationModalComponent, type: :component do
  it 'renders the component' do
    rendered_html = render_inline(described_class.new).to_html
    expect(rendered_html).to include('Enter a title for this deposit')
    expect(rendered_html).to include('(You can update this later.)')
  end
end
