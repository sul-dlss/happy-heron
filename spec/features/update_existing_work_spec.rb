# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Update an existing work in a deposited collection', :js do
  let(:user) { create(:user) }
  let(:collection_version) { create(:collection_version, :deposited, collection:) }
  let(:collection) { create(:collection, :depositor_selects_access, creator: user, depositors: [user]) }
  let(:work_version) { create(:work_version_with_work, collection:, owner: user, title: original_title) }
  let(:original_title) { 'Not an interesting title' }
  let(:new_title) { 'A much better title' }

  before do
    collection.update(head: collection_version)
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  it 'updates the work and adds to the event description history' do
    visit work_path(work_version.work)

    within '#events' do
      # nothing in the history of events yet
      expect(page).to have_no_content 'title of deposit modified, abstract modified'
    end

    click_link_or_button "Edit #{original_title}"

    # breadcrumbs showing
    within '#breadcrumbs' do
      expect(page).to have_content('Dashboard')
      expect(page).to have_content(collection_version.name)
      expect(page).to have_content(original_title)
    end

    # update the title and abstract
    fill_in 'Title of deposit', with: new_title
    fill_in 'Abstract', with: 'I did really cool stuff'

    click_link_or_button 'Save as draft'

    # work detail page has new title
    expect(page).to have_content(new_title)
    expect(page).to have_no_content(original_title)
    expect(page).to have_link(collection_version.name)

    within '#events' do
      # The things that have been updated should only be logged in one event
      expect(page).to have_content 'title of deposit modified, abstract modified', count: 1
    end
  end

  context 'when existing work has more than max_upload_files' do
    let(:work_version) { create(:work_version_with_work, :with_files, collection:, owner: user, title: original_title) }

    before do
      # Setting max_upload_files to 1, while work version has 2 attached files.
      # This situation indicates the files were originally attached by zip or globus upload
      # and because of the number of files, the user is not able to edit them via the UI.
      # However, they must still be added to the new version of the work.
      allow(Settings).to receive(:max_upload_files).and_return(1)
    end

    it 'updates the work keeping attached files' do
      visit work_path(work_version.work)

      click_link_or_button "Edit #{original_title}"

      expect(page).to have_content('You have more than 1 files in your deposit.')
      expect(page).to have_no_content('Unzipping may take several minutes', wait: 0)

      # update the title and abstract
      fill_in 'Title of deposit', with: new_title
      fill_in 'Abstract', with: 'I did really cool stuff'

      click_link_or_button 'Deposit'

      expect(page).to have_content('You have successfully deposited your work')

      visit work_path(work_version.work)

      # work detail page has new title
      expect(page).to have_content(new_title)
      expect(page).to have_no_content(original_title)

      # All files are still attached.
      expect(page).to have_content('favicon.ico')
      expect(page).to have_content('sul.svg')
    end
  end

  context 'when user versions ui feature flag is enabled' do
    let(:test_title) { 'Test title' }
    let(:work) { create(:work, collection:, owner: user) }
    let!(:work_version) do
      create(:work_version, :with_files, :deposited, :with_required_associations,
             work:, version: 1, user_version: 1, title: test_title)
    end
    let(:version2) do
      create(:work_version, :with_files, :deposited, :with_required_associations,
             work:, version: 2, user_version: 2, title: test_title)
    end

    before do
      allow(Settings).to receive(:user_versions_ui_enabled).and_return(true)
      work.update(head: work_version)
    end

    it 'disables the files section for metadata-only changes and keeps files' do
      visit work_path(work_version.work)
      click_link_or_button "Edit #{test_title}"

      expect(page).to have_content('Do you want to create a new version of this deposit?')

      choose('No')
      expect(find_by_id('file-uploads-fieldset')).to be_disabled

      fill_in "What's changing?", with: 'Nothing really'
      click_link_or_button 'Deposit'
      expect(page).to have_content('You have successfully deposited your work')

      version2 = work.reload.head
      expect(version2.reload.version).to eq(2)
      expect(version2.reload.user_version).to eq(1)
      expect(version2.reload.version_description).to eq('Nothing really')
      expect(version2.reload.attached_files.count).to eq(2)
    end

    it 'enables the files section for new user versions and updates files' do
      visit work_path(work)
      click_link_or_button "Edit #{test_title}"
      expect(page).to have_content('Do you want to create a new version of this deposit?')

      choose('Yes')
      expect(find_by_id('file-uploads-fieldset')).not_to be_disabled

      fill_in "What's changing?", with: 'Adding a file'
      # upload a new file
      choose 'work_upload_type_browser'
      page.attach_file(Rails.root.join('spec/fixtures/files/test-data.txt')) do
        click_link_or_button('Choose files')
      end
      sleep 1 # pause to ensure file upload completes before we proceed
      expect(page).to have_content('test-data.txt')

      click_link_or_button 'Deposit'
      expect(page).to have_content('You have successfully deposited your work')

      version2 = work.reload.head
      expect(version2.reload.version).to eq(2)
      expect(version2.reload.user_version).to eq(2)
      expect(version2.reload.version_description).to eq('Adding a file')
      expect(version2.reload.attached_files.count).to eq(3)
    end
  end
end
