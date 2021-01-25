# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new collection', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-collection-creators']
  end

  context 'when successful deposit' do
    let(:collection_attrs) { attributes_for(:collection) }

    it 'deposits and renders work show page' do
      visit dashboard_path

      click_link '+ Create a new collection'

      fill_in 'Collection name', with: collection_attrs.fetch(:name)
      fill_in 'Description', with: collection_attrs.fetch(:description)
      fill_in 'Contact email', with: collection_attrs.fetch(:contact_email)
      check 'Send email to collection Managers and Reviewers when participants are added/removed.'

      expect(page).to have_content('Send email to Depositors whose status has changed.')

      # breadcrumbs showing
      find('#breadcrumbs') do |nav|
        expect(nav).to have_content('Dashboard')
        expect(nav).to have_content('New collection')
      end

      click_button 'Deposit'

      expect(page).to have_content(collection_attrs.fetch(:name))
      # The deposit button is not present until the collection is accessioned
      expect(page).not_to have_content('+ Deposit to this collection')

      # We should not see the delete button for this collection since it is not a draft
      expect(page).not_to have_selector("[aria-label='Delete #{Collection.last.name}']")
    end
  end
end
