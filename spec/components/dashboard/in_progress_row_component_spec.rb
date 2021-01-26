# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work: work)) }
  let(:work) { build_stubbed(:work) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(delete)
  end

  context 'when it can be deleted' do
    let(:delete) { true }

    it 'renders the component' do
      expect(rendered.css('.far.fa-trash-alt')).to be_present
      expect(rendered.to_html).to include work.title
    end
  end

  context 'when it can not be deleted' do
    let(:delete) { false }

    it 'renders the component' do
      expect(rendered.css('.far.fa-trash-alt')).not_to be_present
      expect(rendered.to_html).to include work.title
    end
  end
end
