# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CitationComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version: work_version)) }
  let(:work_version) { build(:work_version) }

  it 'renders the component' do
    button = rendered.css('button').first
    expect(button['data-bs-target']).to eq '#citationModal'
    expect(button['data-controller']).to eq 'show-citation'
  end
end
