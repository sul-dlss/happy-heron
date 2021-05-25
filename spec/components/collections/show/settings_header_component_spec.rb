# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Show::SettingsHeaderComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection_version: collection_version)) }

  context 'with a new, first draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }
    let(:collection_id) { collection_version.collection_id }

    it 'does not render the spinner and renders the edit link' do
      expect(rendered.to_html).not_to include 'fa-spinner'
      expect(rendered.css('a.btn').text).to eq 'Edit or Deposit'
      expect(rendered.css('turbo-frame').first['src']).to eq "/collections/#{collection_id}/edit_link"
    end
  end

  context 'with a depositing collection' do
    let(:collection_version) { build_stubbed(:collection_version, :depositing) }

    it 'does not render the spinner' do
      expect(rendered.to_html).to include 'Depositing'
      expect(rendered.to_html).to include 'fas fa-spinner fa-pulse'
      expect(rendered.css('a.btn')).to be_empty
    end
  end

  context 'when the collection is deposited' do
    let(:collection_version) { build_stubbed(:collection_version, :deposited) }

    it 'does not render the link' do
      expect(rendered.css('a.btn')).to be_empty
    end
  end
end
