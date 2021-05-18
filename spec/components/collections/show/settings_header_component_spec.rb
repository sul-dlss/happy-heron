# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Show::SettingsHeaderComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  before do
    allow(controller).to receive_messages(allowed_to?: true)
  end

  context 'with a new, first draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }

    it 'does not render the spinner' do
      expect(rendered.to_html).not_to include 'fa-spinner'
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
