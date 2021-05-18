# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::CollectionHeaderComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  before do
    allow(controller).to receive_messages(allowed_to?: false)
  end

  context 'with a new, first draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }

    it 'does not render the spinner' do
      expect(rendered.to_html).not_to include 'fa-spinner'
    end

    context 'when allowed to edit' do
      before do
        allow(controller).to receive_messages(allowed_to?: true)
      end

      it 'has an edit button' do
        expect(rendered.css('a').to_html).to include 'Edit'
      end
    end

    context 'when not allowed to edit' do
      it "doesn't have an edit button" do
        expect(rendered.css('a').to_html).not_to include 'Edit'
      end
    end
  end

  context 'with a depositing collection' do
    let(:collection_version) { build_stubbed(:collection_version, :depositing) }

    it 'does not render the spinner' do
      expect(rendered.to_html).to include 'Depositing'
      expect(rendered.to_html).to include 'fas fa-spinner fa-pulse'
    end
  end
end
