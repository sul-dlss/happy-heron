# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionVersionEventDescriptionBuilder do
  subject(:result) { described_class.build(form) }

  let(:collection) { create(:collection) }
  let(:collection_version) { create(:collection_version_with_collection, collection: collection) }
  let(:form) { DraftCollectionForm.new(collection_version: collection_version, collection: collection) }

  context 'when nothing has changed' do
    it { is_expected.to be_blank }
  end

  context 'when name has changed' do
    before do
      form.validate(name: 'new name')
    end

    it { is_expected.to eq 'collection name modified' }
  end

  context 'when many fields have changed' do
    before do
      form.validate(name: 'new name', description: 'foo',
                    contact_emails: [{ 'email' => 'foo@bar.io' }],
                    related_links: [{ 'link_title' => 'Hey', 'url' => 'http://io.io' }])
    end

    it 'has a complete description' do
      expect(result).to eq 'collection name modified, description modified, ' \
                           'contact email modified, related links modified'
    end
  end
end
