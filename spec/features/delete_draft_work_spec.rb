# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:work) { create(:work) }
  let(:user) { work.depositor }

  before do
    sign_in user
  end

  context 'when draft' do
    it 'allow users to delete the work and destroys the model' do
      expect(work).to be_first_draft
      visit dashboard_path
      accept_confirm do
        find("#remove-work-#{work.id}").click
      end
      expect(Work.find_by(id: work.id)).to be(nil)
    end
  end
end
