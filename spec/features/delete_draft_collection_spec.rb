# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft collection', js: true do
  let(:user) { create(:user) }
  let(:collection_attrs) { attributes_for(:collection) }
  let(:collection) { Collection.last }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    visit dashboard_path

    click_link '+ Create a new collection'

    fill_in 'Collection name', with: collection_attrs.fetch(:name)
    click_button 'Save as draft'
  end

  context 'when saved as draft' do
    it 'allow users to delete the collection and destroys the model from the dashboard' do
      expect(collection).to be_first_draft

      visit dashboard_path

      accept_confirm do
        click_link "Delete #{collection.name}"
      end
      expect(Collection.find_by(id: collection.id)).to be(nil)
    end

    it 'allow users to delete the collection and destroys the model from the collection edit page' do
      expect(collection).to be_first_draft

      visit edit_collection_path(collection)

      accept_confirm do
        click_link 'Discard draft'
      end
      expect(Collection.find_by(id: collection.id)).to be(nil)
    end
  end
end
