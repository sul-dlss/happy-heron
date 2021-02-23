# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show the collection work list page' do
  let(:collection) { collection_version.collection }
  let(:collection_version) { create(:collection_version_with_collection) }
  let(:work1) { create(:work, collection: collection) }
  let(:work2) { create(:work, collection: collection) }
  let(:work_version1) { create(:work_version, work: work1) }
  let(:work_version2) { create(:work_version, work: work2) }
  let(:user) { create(:user) }

  before do
    work1.update(head: work_version1)
    work2.update(head: work_version2)
  end

  context 'with an admin user' do
    let(:attached_file) { build(:attached_file, :with_file) }

    before do
      work_version1.update(attached_files: [attached_file])
      attached_file.save!

      sign_in user, groups: [Settings.authorization_workgroup_names.administrators]
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |_work|
        expect(response.body).to include work_version1.title
      end
      expect(response.body).to include '17.3 KB'
    end
  end

  context 'with a manager' do
    before do
      collection.update(managed_by: [user])
      sign_in user
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |_work|
        expect(response.body).to include work_version1.title
      end
    end
  end

  context 'with a reviewer' do
    before do
      collection.update(reviewed_by: [user])
      sign_in user
    end

    it 'displays all of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |_work|
        expect(response.body).to include work_version1.title
      end
    end
  end

  context 'with a depositor' do
    before do
      collection.update(depositors: [user])
      sign_in user
    end

    it 'displays none of the works in the collection' do
      get "/collections/#{collection.id}/works"
      expect(response).to have_http_status(:ok)
      collection.works.each do |_work|
        expect(response.body).not_to include work_version1.title
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
