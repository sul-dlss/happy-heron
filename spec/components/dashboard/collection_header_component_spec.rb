# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::CollectionHeaderComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }

  before do
    allow(controller).to receive_messages(allowed_to?: false)
  end

  context 'with a new, first draft collection' do
    let(:collection) { create(:collection, :first_draft) }

    it 'does not render the spinner' do
      expect(rendered.to_html).not_to include 'fa-spinner'
    end
  end

  context 'with a depositing collection' do
    let(:collection) { create(:collection, :depositing) }

    it 'does not render the spinner' do
      expect(rendered.to_html).to include 'Depositing'
      expect(rendered.to_html).to include 'fas fa-spinner fa-pulse'
    end
  end
end
