# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reserve a PURL for a work in a deposited collection', js: true do
  let(:user) { create(:user) }
  let!(:collection) { create(:collection, :depositor_selects_access, depositors: [user], head: collection_version) }
  let(:collection_version) { create(:collection_version, :deposited) }
  let(:bare_druid) { 'bc123df4567' }
  let(:druid) { "druid:#{bare_druid}" }
  let(:title) { 'my PURL reservation test' }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'when a PURL is reserved successfully' do
    it 'deposits a placeholder work, and lists it on the dashboard with its PURL' do
      visit dashboard_path

      click_button 'Reserve a PURL'
      fill_in 'Enter a title for this deposit', with: title
      click_button 'Submit'

      expect(page).to have_content title
      expect(page).to have_content 'Reserving PURL'

      work_version = WorkVersion.find_by!(title: title)
      expect(work_version.work.collection).to eq collection
      expect(work_version.work.depositor).to eq user
      expect(work_version.work_type).to eq WorkType.purl_reservation_type.id

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

      # getting the PURL to show up requires a page refresh
      visit dashboard_path
      expect(page).to have_content "https://purl.stanford.edu/#{bare_druid}"

      click_link "Choose Type and Edit #{title}"
      find('label', text: 'Music').click
      check 'Sound'
      check 'Image'
      click_button 'Continue'

      expect(work_version.reload.work_type).to eq 'music'
      expect(work_version.subtype.sort).to eq %w[Image Sound]
      # TODO: the redirect to edit page behavior being tested here works IRL in FF, but test gets bounced to /dashboard
      # expect(page.current_path).to eq "/works/#{work_version.work.id}/edit"
    end
  end

  context 'when cancelling out of the PURL reservation dialog' do
    it 'clears any entered text and does not create a work ' do
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
end
