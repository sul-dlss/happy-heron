# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:collection) { create(:collection, :with_depositors, depositor_count: 1) }
  let(:work) { create(:work, collection: collection, depositor: user) }
  let(:work_version) { create(:work_version, title: 'Delete me', work: work) }
  let(:user) { collection.depositors.first }

  before do
    create(:collection_version_with_collection, collection: collection)
    work.update(head: work_version)
    sign_in user
  end

  context 'when draft' do
    it 'allow users to delete the work and destroys the model from the dashboard' do
      visit dashboard_path
      click_button 'No'

      accept_confirm do
        click_link "Delete #{work_version.title}"
      end
      expect(Work.exists?(work.id)).to be false
    end

    it 'allow users to delete the work and destroys the model from the work edit page' do
      visit edit_work_path(work)
      accept_confirm do
        click_link 'Discard draft'
      end
      expect(Work.exists?(work.id)).to be false
    end
  end
end
