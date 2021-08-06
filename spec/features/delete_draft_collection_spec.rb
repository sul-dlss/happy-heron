# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft collection', js: true do
  let(:user) { create(:user) }
  let(:collection) { create(:collection, managed_by: [user]) }
  let(:collection_version) { create(:collection_version, collection: collection) }

  before do
    collection.update(head: collection_version)
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
  end

  context 'when saved as draft' do
    context 'when using the link on the dashboard' do
      it 'allow users to delete the collection and destroys the model' do
        visit dashboard_path

        # There is an occasional problem where the confirmation modal isn't triggered without a delay.
        sleep(0.5)

        accept_confirm do
          within '#your-collections' do
            click_link "Delete #{collection_version.name}"
          end
        end
        expect(Collection.find_by(id: collection.id)).to be(nil)
      end
    end

    context 'when using the link on the collection edit page' do
      it 'allow users to delete the collection and destroys the model' do
        visit edit_collection_version_path(collection_version)

        accept_confirm do
          click_link 'Discard draft'
        end
        expect(Collection.find_by(id: collection.id)).to be(nil)
      end
    end
  end
end
