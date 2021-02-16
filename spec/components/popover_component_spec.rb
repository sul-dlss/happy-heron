# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PopoverComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(key: :what_type)) }

  it 'renders the component' do
    expect(rendered.css('a').first['data-bs-content']).to eq 'Choose the one content type ' \
      'that best describes the overall or primary nature of the work. Click on each content ' \
      'type to view and select terms you may use to further describe the work you are depositing.'
  end
end
