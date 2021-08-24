# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reserve a PURL for a work in a deposited collection', js: true do
  let(:user) { create(:user) }
  let!(:collection) do
    create(:collection, :depositor_selects_access, managed_by: [user], head: collection_version, doi_option: doi_option)
  end
  let(:collection_version) { create(:collection_version, :deposited) }
  let(:druid) { 'druid:bc123df4567' }
  let(:title) { 'my PURL reservation test' }
  let(:doi_option) { 'depositor-selects' }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  it 'deposits a placeholder work, and lists it on the dashboard with its PURL, then remove it' do
    visit dashboard_path

    click_button 'Reserve a PURL'
    fill_in 'Enter a title for this deposit', with: title
    expect(page).to have_content 'Do you want a DOI to be assigned to your deposit?'
    click_button 'Submit'

    expect(page).to have_content title
    expect(page).to have_content 'Reserving PURL'

    work_version = WorkVersion.find_by!(title: title)
    expect(work_version.work.collection).to eq collection
    expect(work_version.work.depositor).to eq user
    expect(work_version.work_type).to eq WorkType.purl_reservation_type.id
    expect(work_version.work.assign_doi?).to be true

    # IRL, dor-services-app would send a message that RabbitMQ would route to h2.druid_assigned,
    # for processing by AssignPidJob, so we'll just fake that by running the job manually
    source_id = "hydrus:object-#{work_version.work.id}"
    identification = instance_double(Cocina::Models::Identification, sourceId: source_id)
    model = instance_double(Cocina::Models::DRO, identification: identification, externalIdentifier: druid)
    assign_pid_job = AssignPidJob.new
    allow(assign_pid_job).to receive(:build_cocina_model_from_json_str).and_return(model)
    assign_pid_job.work('{}') # don't need to fake JSON for fully valid Cocina model, just mock resulting DRO

    # this should be updated automatically
    expect(page).to have_content 'PURL Reserved'

    # now delete the reserved purl and confirm it is gone
    accept_confirm do
      within '#your-collections-table' do
        click_link "Delete #{work_version.title}"
      end
    end
    sleep(1)
    expect(WorkVersion.exists?(work_version.id)).to be false
  end

  context 'when depositor cannot select DOI' do
    let(:doi_option) { 'no' }

    it 'deposits a placeholder work' do
      visit dashboard_path

      click_button 'Reserve a PURL'
      fill_in 'Enter a title for this deposit', with: title
      expect(page).not_to have_content 'Do you want a DOI to be assigned to your deposit?'
      click_button 'Submit'

      expect(page).to have_content title
      expect(page).to have_content 'Reserving PURL'

      work_version = WorkVersion.find_by!(title: title)
      expect(work_version.work.assign_doi?).to be false
    end
  end

  describe 'setting the type for a reserved purl' do
    let!(:work_version) do
      create(:work_version_with_work, :purl_reserved, collection: collection, depositor: user)
    end

    it 'from the dashboard' do
      visit dashboard_path

      within_table collection_version.name do
        click_link "Choose Type and Edit #{work_version.title}"
      end
      find('label', text: 'Music').click
      check 'Sound'
      check 'Image'
      click_button 'Continue'

      expect(work_version.reload.work_type).to eq 'music'
      expect(work_version.subtype.sort).to eq %w[Image Sound]
      expect(page).to have_content "What's changing?"
    end

    it 'from the collection works list' do
      visit collection_works_path(collection)

      click_link "Choose Type and Edit #{work_version.title}"
      find('label', text: 'Music').click
      check 'Sound'
      check 'Image'
      click_button 'Continue'

      expect(work_version.reload.work_type).to eq 'music'
      expect(work_version.subtype.sort).to eq %w[Image Sound]
      expect(page).to have_content "What's changing?"
    end

    it 'from the work show page' do
      visit work_path(work_version.work)

      click_link "Choose Type and Edit #{work_version.title}"
      find('label', text: 'Music').click
      check 'Sound'
      check 'Image'
      click_button 'Continue'

      expect(work_version.reload.work_type).to eq 'music'
      expect(work_version.subtype.sort).to eq %w[Image Sound]
      expect(page).to have_content "What's changing?"
    end
  end

  it 'when cancelling out of the PURL reservation dialog' do
    visit dashboard_path

    click_button 'Reserve a PURL'
    fill_in 'Enter a title for this deposit', with: title
    click_button 'Cancel'

    click_button 'Reserve a PURL'
    expect(page).not_to have_content title

    visit dashboard_path
    expect(page).not_to have_content title
    expect(WorkVersion.find_by(title: title)).to be nil
  end
end
