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
    before { sign_in user, groups: ['dlss:hydrus-app-administrators'] }

    it 'shows a link to create collections' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'Your collections'
      expect(response.body).to include '+ Create a new collection'
    end
  end

  context 'when user is a reviewer' do
    let(:collection) { create(:collection, :with_reviewers) }
    let(:user) { collection.reviewers.first }

    before do
      create(:work, collection: collection, state: 'pending_approval', title: 'To Review')
      create(:work, collection: collection, state: 'first_draft', title: 'No Review')
      sign_in user
    end

    it 'shows a link to create collections' do
      get '/dashboard'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include 'To Review'
      expect(response.body).not_to include 'No Review'
    end
  end

  context 'when user is a depositor in a collection with reviewers' do
    let(:collection) { create(:collection, :with_depositors) }
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
    let(:collection) { create(:collection, :with_reviewers, :with_depositors) }
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
      expect(response.body).to include Works::StateDisplayComponent::STATE_DISPLAY_LABELS['pending_approval']
      expect(response.body).to include Works::StateDisplayComponent::STATE_DISPLAY_LABELS['first_draft']
      expect(response.body).to include Works::StateDisplayComponent::STATE_DISPLAY_LABELS['rejected']
    end
  end
end
