# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the collection work list page' do
  let(:collection) { create(:collection, :with_works) }

  context 'with an admin user' do
    let(:user) { create(:user) }
    let(:attached_file) { build(:attached_file, :with_file) }

    before do
      collection.works.first.attached_files = [attached_file]
      attached_file.save!

      sign_in user, groups: [Settings.authorization_workgroup_names.administrators]
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |work|
        expect(response.body).to include work.title
      end
      expect(response.body).to include '17.3 KB'
    end
  end

  context 'with a manager' do
    let(:collection) { create(:collection, :with_managers, :with_works) }
    let(:user) { collection.managed_by.first }

    before do
      sign_in user
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |work|
        expect(response.body).to include work.title
      end
    end
  end

  context 'with a reviewer' do
    let(:collection) { create(:collection, :with_reviewers, :with_works) }
    let(:user) { collection.reviewed_by.first }

    before do
      sign_in user
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |work|
        expect(response.body).to include work.title
      end
    end
  end

  context 'with a depositor' do
    let(:collection) { create(:collection, :with_depositors, :with_works) }
    let(:user) { collection.depositors.first }

    before do
      sign_in user
    end

    it 'displays none of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |work|
        expect(response.body).not_to include work.title
      end
    end
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id to login URL' do
      get "/collections/#{collection.id}/works"
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
