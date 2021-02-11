# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard requests' do
  let(:user) { create(:user) }
  let(:collection_manager) { create(:user) }

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
    let(:work1) { create(:work, depositor: user) }
    let(:work_version1) { create(:work_version, title: 'Happy little title', work: work1) }
    let(:work_version2) { create(:work_version, title: 'Secret') }

    before do
      work1.update(head: work_version1)
      work_version2.work.update(head: work_version2)
      sign_in user
    end

    it 'shows the deposits that belong to the user' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include 'Happy little title'
      expect(response.body).not_to include 'Secret'
    end
  end

  context 'when user has a draft deposit with no title' do
    let(:work1) { create(:work, depositor: user) }
    let(:work_version1) { create(:work_version, title: '', work: work1) }
    let(:work_version2) { create(:work_version, title: 'Secret') }

    before do
      work1.update(head: work_version1)
      work_version2.work.update(head: work_version2)
      sign_in user
    end

    it 'shows the deposits that belong to the user with the default title' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include 'No title' # this is the default title when none is provided for a draft
      expect(response.body).not_to include 'Secret'
    end
  end

  context 'when user is a collection manager and there is a collection in progress' do
    let(:collection) do
      create(:collection, :first_draft, creator: user, managed_by: [collection_manager], name: 'Happy collection')
    end
    let(:work) { create(:work, collection: collection, depositor: collection_manager) }
    let(:work_version) { create(:work_version, work: work) }

    before do
      work.update(head: work_version)
      sign_in collection_manager
    end

    it 'shows the collection in progress' do
      get '/dashboard'
      expect(response).to be_successful
      expect(response.body).to include('Collections in progress')
      expect(response.body).to include(collection.name)
    end
  end

  context 'when user has in progress deposits in different states' do
    let(:work1) { create(:work, depositor: user) }
    let(:work_version1) { create(:work_version, state: 'first_draft', title: 'I am a first draft', work: work1) }
    let(:work2) { create(:work, depositor: user) }
    let(:work_version2) { create(:work_version, state: 'version_draft', title: 'I am a version draft', work: work2) }
    let(:work3) { create(:work, depositor: user) }
    let(:work_version3) { create(:work_version, state: 'rejected', title: 'I am rejected', work: work3) }
    let(:work4) { create(:work, depositor: user) }
    let(:work_version4) { create(:work_version, state: 'deposited', title: 'I am deposited', work: work4) }
    let(:work5) { create(:work, depositor: user) }
    let(:work_version5) { create(:work_version, state: 'depositing', title: 'I am depositing', work: work5) }
    let(:work6) { create(:work, depositor: user) }
    let(:work_version6) do
      create(:work_version, state: 'pending_approval', title: 'I am a pending approval', work: work6)
    end

    before do
      work1.update(head: work_version1)
      work2.update(head: work_version2)
      work3.update(head: work_version3)
      work4.update(head: work_version4)
      work5.update(head: work_version5)
      work6.update(head: work_version6)

      sign_in user
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

    let(:work1) { create(:work, depositor: user, collection: workful_collection) }
    let(:work_version1) { create(:work_version, state: 'deposited', work: work1) }
    let(:work2) { create(:work, depositor: user, collection: workful_collection) }
    let(:work_version2) { create(:work_version, state: 'first_draft', work: work2) }
    let(:work3) { create(:work, depositor: user, collection: workful_collection) }
    let(:work_version3) { create(:work_version, state: 'version_draft', work: work3) }
    let(:work4) { create(:work, depositor: user, collection: workful_collection) }
    let(:work_version4) { create(:work_version, state: 'pending_approval', work: work4) }
    let(:work5) { create(:work, depositor: user, collection: workful_collection) }
    let(:work_version5) { create(:work_version, state: 'rejected', work: work5) }

    before do
      work1.update(head: work_version1)
      work2.update(head: work_version2)
      work3.update(head: work_version3)
      work4.update(head: work_version4)
      work5.update(head: work_version5)

      sign_in user, groups: ['dlss:hydrus-app-administrators']
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
    let(:work) { create(:work, collection: collection) }
    let(:work_version) { create(:work_version, :pending_approval, title: 'To Review', work: work) }

    before do
      work.update(head: work_version)
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
    let(:work) { create(:work, depositor: user) }

    before do
      create(:work_version, work: work) # Must have a deposit to visit the dashboard
      sign_in user
    end

    it 'shows a link to deposit in the collection' do
      get deposit_button_collection_path(collection)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Deposit to this collection'
    end
  end

  context 'when collection has reviewers' do
    let(:collection) { create(:collection, :deposited, :with_reviewers, :with_depositors) }
    let(:user) { collection.depositors.first }

    let(:work1) { create(:work, depositor: user, collection: collection) }
    let(:work_version1) { create(:work_version, :pending_approval, title: 'To Review', work: work1) }
    let(:work2) { create(:work, depositor: user, collection: collection) }
    let(:work_version2) { create(:work_version, :first_draft, title: 'No Review', work: work2) }
    let(:work3) { create(:work, depositor: user, collection: collection) }
    let(:work_version3) { create(:work_version, :rejected, title: 'Rejected Upon Review', work: work3) }

    before do
      work1.update(head: work_version1)
      work2.update(head: work_version2)
      work3.update(head: work_version3)
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
