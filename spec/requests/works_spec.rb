# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Works requests' do
  let(:work) { create(:work) }
  let(:collection) { create(:collection) }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
  end

  context 'with unauthenticated user' do
    before do
      sign_out
    end

    it 'redirects from /collections/:collection_id/works/new to login URL' do
      get "/collections/#{collection.id}/works/new"
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'allows GETs to /works/:work_id' do
      get "/works/#{work.id}"
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in user
    end

    describe 'show a work' do
      it 'displays the work' do
        get "/works/#{work.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'new work form' do
      it 'renders the form' do
        get "/collections/#{collection.id}/works/new?work_type=video"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'video'
      end
    end

    context 'when Settings.allow_sdr_content_changes is' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }

      it 'false, it redirects and displays alert' do
        allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        get "/collections/#{collection.id}/works/new?work_type=text"
        expect(response).to redirect_to(:root)
        follow_redirect!
        expect(response).to be_successful
        expect(response.body).to include alert_text
      end

      it 'true, it does NOT display alert' do
        get "/collections/#{collection.id}/works/new?work_type=other"
        expect(response).to be_successful
        expect(response.body).not_to include alert_text
      end
    end

    describe 'create work' do
      let(:collection) { create(:collection) }

      let(:contributors) do
        { '0' =>
          { '_destroy' => '1', 'first_name' => 'Justin',
            'last_name' => 'Coyne', 'role_term' => 'person|Collector' },
          '999' =>
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'role_term' => 'person|Author' },
          '1002' =>
          { '_destroy' => 'false', 'first_name' => 'Vivian',
            'last_name' => 'Wong', 'role_term' => 'person|Contributing author' } }
      end

      let(:upload) { fixture_file_upload(Rails.root.join('public/apple-touch-icon.png'), 'image/png') }

      let(:files) do
        { '0' =>
          { '_destroy' => '1', 'label' => 'Wrong PDF',
            'file' => upload },
          '999' =>
          { '_destroy' => 'false', 'label' => 'My PNG',
            'file' => upload },
          '1002' =>
          { '_destroy' => 'false', 'label' => 'My PDF',
            'file' => upload } }
      end
      let(:work_params) do
        attributes_for(:work)
          .merge(contributors_attributes: contributors,
                 attached_files_attributes: files,
                 'published(1i)' => '2020', 'published(2i)' => '2', 'published(3i)' => '14',
                 creation_type: 'range',
                 'created(1i)' => '2020', 'created(2i)' => '2', 'created(3i)' => '14',
                 'created_range(1i)' => '2020', 'created_range(2i)' => '3', 'created_range(3i)' => '4',
                 'created_range(4i)' => '2020', 'created_range(5i)' => '10', 'created_range(6i)' => '31')
      end

      it 'displays the work' do
        post "/collections/#{collection.id}/works", params: { work: work_params }
        expect(response).to have_http_status(:found)
        work = Work.last
        expect(work.contributors.size).to eq 2
        expect(work.attached_files.size).to eq 2
        expect(work.published_edtf).to eq '2020-02-14'
        expect(work.created_edtf).to eq '2020-03-04/2020-10-31'
        expect(work.subtype).to eq ['3D model', 'GIS']
      end
    end
  end
end
