# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:work) { create(:work, title: 'Delete me') }
  let(:user) { work.depositor }

  before do
    sign_in user
  end

  context 'when draft' do
    it 'allow users to delete the work and destroys the model from the dashboard' do
      expect(work).to be_first_draft
      visit dashboard_path
      accept_confirm do
        click_link "Delete #{work.title}"
      end
      expect(Work.find_by(id: work.id)).to be(nil)
    end

    it 'allow users to delete the work and destroys the model from the work edit page' do
      expect(work).to be_first_draft
      visit edit_work_path(work)
      accept_confirm do
        click_link 'Discard draft'
      end
      expect(Work.find_by(id: work.id)).to be(nil)
    end
  end
end
