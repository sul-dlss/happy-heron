# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard requests' do
  let(:user) { create(:user) }

  context 'when user has no deposits' do
    before { sign_in user }

    it 'returns an unauthorized http status code' do
      get '/dashboard'
      expect(response).to redirect_to(:root)
      follow_redirect!
      expect(response).to be_successful
      expect(response.body).to include 'You are not authorized to perform the requested action'
    end
  end

  context 'when user has deposits' do
    before do
      sign_in user
      create(:work, depositor: user, title: 'Happy little title')
      create(:work, title: 'Secret')
    end

    it 'shows the deposits that belong to the user' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include 'Happy little title'
      expect(response.body).not_to include 'Secret'
    end
  end

  context 'when user has a draft deposit with no title' do
    before do
      sign_in user
      create(:work, depositor: user, title: '')
      create(:work, title: 'Secret')
    end

    it 'shows the deposits that belong to the user with the default title' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include 'No title' # this is the default title when none is provided for a draft
      expect(response.body).not_to include 'Secret'
    end
  end

  context 'when user has in progress deposits in different states' do
    before do
      sign_in user
      create(:work, depositor: user, state: 'first_draft', title: 'I am a first draft')
      create(:work, depositor: user, state: 'version_draft', title: 'I am a version draft')
      create(:work, depositor: user, state: 'rejected', title: 'I am rejected')
      create(:work, depositor: user, state: 'deposited', title: 'I am deposited')
      create(:work, depositor: user, state: 'depositing', title: 'I am depositing')
      create(:work, depositor: user, state: 'pending_approval', title: 'I am pending approval')
    end

    it 'shows draft and rejected deposits as being in progress' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include('I am a first draft')
      expect(response.body).to include('I am a version draft')
      expect(response.body).to include('I am rejected')
      expect(response.body).not_to include('I am deposited')
      expect(response.body).not_to include('I am depositing')
      expect(response.body).not_to include('I am pending approval')
    end
  end

  context 'when user has the collection creator LDAP role' do
    before { sign_in user, groups: ['dlss:hydrus-app-collection-creators'] }

    it 'shows links to create in a collection' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Your collections'
      expect(response.body).to include '+ Create a new collection'
    end
  end

  context 'when user is an application admin' do
    let(:workful_collection) { create(:collection, creator: user, updated_at: '2020-12-02') }
    let!(:workless_collection) { create(:collection, creator: user, updated_at: '2020-12-03') }

    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
      create(:work, :deposited, collection: workful_collection, depositor: user)
      create(:work, :first_draft, collection: workful_collection, depositor: user)
      create(:work, :version_draft, collection: workful_collection, depositor: user)
      create(:work, :pending_approval, collection: workful_collection, depositor: user)
      create(:work, :rejected, collection: workful_collection, depositor: user)
    end

    it 'shows a link to create collections and the all collections table' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Your collections'
      expect(response.body).to include '+ Create a new collection'
      expect(response.body).to include <<-HTML
      <tr>
        <td><a href=\"#{collection_path(workful_collection)}\">MyString</a></td>
        <td>5</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>Dec 02, 2020</td>
      </tr>
      HTML
      expect(response.body).to include <<-HTML
      <tr>
        <td><a href=\"#{collection_path(workless_collection)}\">MyString</a></td>
        <td>0</td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td>Dec 03, 2020</td>
      </tr>
      HTML
    end
  end

  context 'when user is a reviewer' do
    let(:collection) { create(:collection, :deposited, :with_reviewers) }
    let(:user) { collection.reviewed_by.first }

    before do
      create(:work, collection: collection, state: 'pending_approval', title: 'To Review')
      sign_in user
    end

    it 'shows the collection to review' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'To Review'
    end
  end

  context 'when user is a depositor in a collection with reviewers' do
    let(:collection) { create(:collection, :deposited, :with_depositors) }
    let(:user) { collection.depositors.first }

    before do
      create(:work, depositor: user) # Must have a deposit to visit the dashboard
      sign_in user
    end

    it 'shows a link to deposit in the collection' do
      get collection_deposit_button_path(collection)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Deposit to this collection'
    end
  end

  context 'when collection has reviewers' do
    let(:collection) { create(:collection, :deposited, :with_reviewers, :with_depositors) }
    let(:user) { collection.depositors.first }

    before do
      create(:work, depositor: user, collection: collection, state: 'pending_approval', title: 'To Review')
      create(:work, depositor: user, collection: collection, state: 'first_draft', title: 'No Review')
      create(:work, depositor: user, collection: collection, state: 'rejected', title: 'Rejected Upon Review')
      sign_in user
    end

    it 'shows statuses Pending Approval, Returned, First Draft' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Pending approval'
      expect(response.body).to include 'Draft - Not deposited'
      expect(response.body).to include 'Returned'

      # and a link to edit
      expect(response.body).to include 'Edit'
    end
  end
end
