# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewCollectionVersionService do
  let(:new_version) do
    described_class.dup(existing_version, increment_version: true, save: true, version_description: 'A dup',
                                          state: :version_draft)
  end

  let(:existing_version) do
    create(:collection_version_with_collection)
  end

  before do
    create(:related_link, linkable: existing_version)
    create(:contact_email, emailable: existing_version)
  end

  it 'duplicates the version' do
    expect(new_version).to be_a CollectionVersion
    expect(new_version.persisted?).to be true
    expect(new_version.version).to be 2
    expect(new_version.version_description).to eq 'A dup'
    expect(new_version.version_draft?).to be true
    existing_version.reload
    expect(new_version.name).to eq existing_version.name
    expect(new_version.collection).to eq existing_version.collection
    expect(existing_version.collection.head).to eq new_version
    expect(new_version.related_links.count).to eq 1
    expect(new_version.contact_emails.count).to eq 1
  end
end
