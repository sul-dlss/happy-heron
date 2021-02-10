# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:work) { work_version.work }
  let(:work_version) { create(:work_version, title: 'Delete me') }
  let(:user) { work.depositor }

  before do
    work.update(head: work_version)
    sign_in user
  end

  context 'when draft' do
    it 'allow users to delete the work and destroys the model from the dashboard' do
      visit dashboard_path
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
