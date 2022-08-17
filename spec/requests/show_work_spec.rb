# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show a work detail' do
  let(:collection) { create(:collection_version_with_collection).collection }
  let(:work) { create(:work, collection: collection) }
  let(:work_version) { create(:work_version, work: work) }

  before do
    work.update(head: work_version)
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /works/:work_id to login URL' do
      get "/works/#{work.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'with an unauthorized user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    it 'redirects from /works/:work_id to the root path' do
      get "/works/#{work.id}"
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include 'You are not authorized to perform the requested action'
    end
  end

  context 'with an authorized user' do
    let(:user) { work.owner }

    before do
      sign_in user
      get "/works/#{work.id}"
    end

    it 'displays the work' do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include work_version.title
      # Owner is different than depositor, so displayed.
      # Matching on "Owner" but not "Ownership".
      expect(response.body).to match(/Owner(?!ship)/)
    end

    context 'when the work has a blank title' do
      let(:work_version) { create(:work_version, title: '', work: work) }

      it 'displays a default title for a work when it is blank' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'No title'
      end
    end

    context 'when work opener is same as depositor' do
      let(:user) { create(:user) }

      let(:work) { create(:work, collection: collection, owner: user, depositor: user) }

      it 'does not display the owner' do
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to match(/Owner(?!ship)/)
      end
    end
  end
end
