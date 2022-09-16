# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:collection) { create(:collection, :with_depositors, depositor_count: 1) }
  let(:work) { create(:work, collection:, owner: user) }
  let(:work_version) { create(:work_version, title: 'Delete me', work:) }
  let(:work_pending_approval) { create(:work, collection:, owner: user) }
  let(:work_version_pending_approval) do
    create(:work_version, :pending_approval, title: 'Pending Approval - Delete me', work: work_pending_approval)
  end
  let(:work_rejected) { create(:work, collection:, owner: user) }
  let(:work_version_rejected) { create(:work_version, :rejected, title: 'Rejected - Delete me', work: work_rejected) }
  let(:user) { collection.depositors.first }

  before do
    create(:collection_version_with_collection, collection:)
    sign_in user
  end

  context 'when draft' do
    before { work.update(head: work_version) }

    it 'allow users to delete the work and destroys the model from the dashboard' do
      visit dashboard_path
      click_button 'No' # dismiss the "Would you like to continue to working on your draft ..." dialog

      accept_confirm do
        within '#deposits-in-progress' do
          click_link "Delete #{work_version.title}"
        end
      end
      sleep(1)
      expect(Work.exists?(work.id)).to be false
    end

    it 'allow users to delete the work and destroys the model from the work edit page' do
      visit edit_work_path(work)
      accept_confirm do
        click_link 'Discard draft'
      end
      expect(Work.exists?(work.id)).to be false
      expect(page).to have_current_path(collection_works_path(collection.id))
    end
  end

  context 'when pending approval' do
    before { work_pending_approval.update(head: work_version_pending_approval) }

    it 'allow users to delete the work and destroys the model from the dashboard' do
      visit dashboard_path

      accept_confirm do
        within '#your-collections' do
          click_link "Delete #{work_version_pending_approval.title}"
        end
      end
      sleep(1)
      expect(Work.exists?(work_pending_approval.id)).to be false
    end
  end

  context 'when rejected' do
    before { work_rejected.update(head: work_version_rejected) }

    it 'allow users to delete the work and destroys the model from the dashboard' do
      visit dashboard_path
      click_button 'No' # dismiss the "Would you like to continue to working on your draft ..." dialog

      accept_confirm do
        within '#your-collections' do
          click_link "Delete #{work_version_rejected.title}"
        end
      end
      sleep(1)
      expect(Work.exists?(work_rejected.id)).to be false
    end

    it 'allow users to delete the work and destroys the model from the work edit page' do
      visit edit_work_path(work_rejected)
      accept_confirm do
        click_link 'Discard draft'
      end
      expect(Work.exists?(work_rejected.id)).to be false
      expect(page).to have_current_path(collection_works_path(collection.id))
    end
  end
end
