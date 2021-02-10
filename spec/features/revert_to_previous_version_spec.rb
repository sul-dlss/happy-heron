# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', js: true do
  let(:work) { create(:work) }
  let!(:version1) { create(:work_version, :deposited, version: 1, title: 'First version', work: work) }
  let(:version2) { create(:work_version, :version_draft, version: 2, title: 'Second version', work: work) }
  let(:user) { work.depositor }

  before do
    work.update(head: version2)
    sign_in user
  end

  it 'allow users to delete the work and destroys the model from the work edit page' do
    visit edit_work_path(work)
    accept_confirm do
      click_link 'Discard draft'
    end
    expect(WorkVersion).to exist(version1.id)
    expect(WorkVersion).not_to exist(version2.id)
    expect(work.reload.head).to eq version1
  end
end
