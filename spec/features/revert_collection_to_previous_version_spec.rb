# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft collection', js: true do
  let(:collection) { create(:collection, :with_managers, manager_count: 1) }
  let!(:version1) { create(:collection_version, :deposited, version: 1, collection:) }
  let(:version2) { create(:collection_version, :version_draft, version: 2, collection:) }
  let(:user) { collection.managed_by.first }

  before do
    collection.update(head: version2)
    sign_in user
  end

  it 'reverts to the previous version' do
    visit edit_collection_version_path(version2)
    accept_confirm do
      click_link 'Discard draft'
    end
    expect(CollectionVersion).to exist(version1.id)
    expect(CollectionVersion).not_to exist(version2.id)
    expect(collection.reload.head).to eq version1
  end
end
