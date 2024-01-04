# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Delete a draft work', :js do
  let(:collection) { create(:collection_version_with_collection).collection }
  let(:work) { create(:work, collection:) }
  let!(:version1) { create(:work_version, :deposited, version: 1, work:) }
  let(:version2) { create(:work_version, :version_draft, version: 2, work:) }
  let(:user) { work.owner }

  before do
    work.update(head: version2)
    sign_in user
  end

  it 'reverts to the previous version' do
    visit edit_work_path(work)
    accept_confirm do
      click_link_or_button 'Discard draft'
    end
    expect(WorkVersion).to exist(version1.id)
    expect(WorkVersion).not_to exist(version2.id)
    expect(work.reload.head).to eq version1
  end
end
