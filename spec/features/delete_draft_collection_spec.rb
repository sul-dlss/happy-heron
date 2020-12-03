# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft collection', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
  end

  context 'when saved as draft' do
    let(:collection_attrs) { attributes_for(:collection) }

    it 'allow users to delete the collection and destroys the model' do
      visit dashboard_path

      click_link '+ Create a new collection'

      fill_in 'Collection name', with: collection_attrs.fetch(:name)
      click_button 'Save as draft'

      collection = Collection.last
      expect(collection).to be_first_draft
      accept_confirm do
        find("#remove-collection-#{collection.id}").click
      end
      expect(Collection.find_by(id: collection.id)).to be(nil)
    end
  end
end
