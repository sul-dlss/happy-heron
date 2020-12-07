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
    let(:collection) { create(:collection, creator: user, updated_at: '2020-12-02') }

    before do
      sign_in user, groups: ['dlss:hydrus-app-administrators']
      create(:work, :deposited, collection: collection, depositor: user)
      create(:work, :first_draft, collection: collection, depositor: user)
      create(:work, :version_draft, collection: collection, depositor: user)
      create(:work, :pending_approval, collection: collection, depositor: user)
      create(:work, :rejected, collection: collection, depositor: user)
    end

    it 'shows a link to create collections and the all collections table' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Your collections'
      expect(response.body).to include '+ Create a new collection'
      expect(response.body).to include <<-HTML
      <tr>
        <td><a href=\"#{collection_path(collection)}\">MyString</a></td>
        <td>5</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>Dec 02, 2020</td>
      </tr>
      HTML
    end
  end

  context 'when user is a reviewer' do
    let(:collection) { create(:collection, :deposited, :with_reviewers) }
    let(:user) { collection.reviewers.first }

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
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Deposit to this collection'
      expect(response.body).not_to include 'Edit'
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

    it 'shows a link to deposit in the collection' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Deposit to this collection'
      expect(response.body).to include 'Edit'
    end

    it 'shows statuses Pending Approval, Returned, First Draft' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Pending approval'
      expect(response.body).to include 'Draft - Not deposited'
      expect(response.body).to include 'Returned'
    end
  end
end
