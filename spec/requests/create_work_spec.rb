# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new work' do
  let(:work) { create(:work) }
  let(:collection) { create(:collection, :deposited) }

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
  end

  context 'with an authenticated user' do
    let(:user) { create(:user) }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    describe 'new work form' do
      let(:collection) { create(:collection, :deposited, depositors: [user]) }

      it 'renders the form' do
        get "/collections/#{collection.id}/works/new?work_type=video"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'video'
      end

      context 'with a missing work type' do
        it 'redirects to dashboard with an informative flash message' do
          get "/collections/#{collection.id}/works/new?work_type="
          expect(response).to redirect_to(dashboard_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid value of required parameter work_type: missing'
        end
      end

      context 'with an invalid work type' do
        it 'redirects to dashboard with an informative flash message' do
          get "/collections/#{collection.id}/works/new?work_type=hyrax"
          expect(response).to redirect_to(dashboard_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid value of required parameter work_type: hyrax'
        end
      end

      context 'with an invalid work type and subtypes' do
        it 'redirects to dashboard with an informative flash message' do
          get "/collections/#{collection.id}/works/new?work_type=hyrax&subtype%5B%5D=Tusks"
          expect(response).to redirect_to(dashboard_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid value of required parameter work_type: hyrax'
          expect(response.body).to include 'Invalid subtype value for work_type &#39;hyrax&#39;: Tusks'
        end
      end

      context 'with an invalid subtype/work_type combo' do
        it 'redirects to dashboard with an informative flash message' do
          get "/collections/#{collection.id}/works/new?work_type=sound&subtype%5B%5D=Essay"
          expect(response).to redirect_to(dashboard_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid subtype value for work_type &#39;sound&#39;: Essay'
        end
      end

      context 'with a work_type that is missing a required user-supplied subtype' do
        it 'redirects to dashboard with an informative flash message' do
          get "/collections/#{collection.id}/works/new?work_type=other"
          expect(response).to redirect_to(dashboard_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Invalid subtype value for work_type &#39;other&#39;: missing'
        end
      end

      context 'with a work_type that has a required user-supplied subtype' do
        it 'renders the form' do
          get "/collections/#{collection.id}/works/new?work_type=other&subtype%5B%5D=Awesome+Subtype"
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'Awesome Subtype'
        end
      end

      context 'with a valid subtype/work_type combo' do
        it 'renders the form' do
          get "/collections/#{collection.id}/works/new?work_type=text&subtype%5B%5D=Essay"
          expect(response).to have_http_status(:ok)
          expect(response.body).to include 'text'
        end
      end
    end

    describe 'allowing content changes' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }
      let(:collection) { create(:collection, :deposited, depositors: [user]) }

      context 'when false' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(false)
        end

        it 'redirects and displays alert' do
          get "/collections/#{collection.id}/works/new?work_type=text"
          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response).to have_http_status(:ok)
          expect(response.body).to include alert_text
        end
      end

      context 'when true' do
        before do
          allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
        end

        it 'does NOT display alert' do
          get "/collections/#{collection.id}/works/new?work_type=text"
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include alert_text
        end
      end
    end

    describe 'create work' do
      before do
        allow(DepositJob).to receive(:perform_later)
      end

      context 'when a collection allows embargo but restricts access and with everything' do
        let(:collection) do
          create(:collection, :deposited, depositors: [user], release_option: 'depositor-selects')
        end

        let(:contributors) do
          { '0' =>
            { '_destroy' => '1', 'first_name' => 'Justin',
              'last_name' => 'Coyne', 'role_term' => 'person|Data collector' },
            '999' =>
            { '_destroy' => 'false', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'full_name' => 'Stanford', 'role_term' => 'person|Author' },
            '1002' =>
            { '_destroy' => 'false', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'full_name' => 'The Leland Stanford Junior University',
              'role_term' => 'organization|Host institution' } }
        end

        let(:upload1) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('public/apple-touch-icon.png')),
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:upload2) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('spec/fixtures/files/favicon.ico')),
            filename: 'favicon.ico',
            content_type: 'image/vnd.microsoft.icon'
          )
        end

        let(:upload3) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
            filename: 'sul.svg',
            content_type: 'image/svg+xml'
          )
        end

        let(:files) do
          {
            '0' => {
              '_destroy' => '1',
              'label' => 'Wrong ICO',
              'file' => upload1.signed_id
            },
            '999' => {
              '_destroy' => 'false',
              'label' => 'My ICO',
              'hide' => false,
              'file' => upload2.signed_id
            },
            '1002' => {
              '_destroy' => 'false',
              'label' => 'My SVG',
              'hide' => false,
              'file' => upload3.signed_id
            }
          }
        end

        let(:keywords) do
          { '0' =>
            { '_destroy' => 'false', 'label' => 'Feminism',
              'uri' => 'http://id.worldcat.org/fast/922671' },
            '999' =>
            { '_destroy' => '1', 'label' => 'My PNG',
              'uri' => '' },
            '1002' =>
            { '_destroy' => 'false', 'label' => 'Freeform keyword',
              'uri' => '' } }
        end

        let(:related_works) do
          {
            '0' =>
            { '_destroy' => 'false', 'citation' => 'citation 1' },
            '999' =>
            { '_destroy' => '1', 'citation' => 'citation 2' },
            '1002' =>
            { '_destroy' => 'false', 'citation' => 'citation 3' }
          }
        end

        let(:related_links) do
          {
            '0' =>
            { '_destroy' => 'false', 'link_title' => 'link 1', 'url' => 'https://example.com' },
            '999' =>
            { '_destroy' => '1', 'link_title' => 'link 2', 'url' => 'https://example.com' },
            '1002' =>
            { '_destroy' => 'false', 'link_title' => 'link 3', 'url' => 'https://example.com' }
          }
        end

        let(:embargo_year) { Time.zone.today.year + 1 }

        let(:work_params) do
          attributes_for(:work)
            .merge(contributors_attributes: contributors,
                   attached_files_attributes: files,
                   keywords_attributes: keywords,
                   related_works_attributes: related_works,
                   related_links_attributes: related_links,
                   default_citation: false,
                   'published(1i)' => '2020', 'published(2i)' => '2', 'published(3i)' => '14',
                   created_type: 'range',
                   'created(1i)' => '2020', 'created(2i)' => '2', 'created(3i)' => '14',
                   'created_range(1i)' => '2020', 'created_range(2i)' => '3', 'created_range(3i)' => '4',
                   'created_range(4i)' => '2020', 'created_range(5i)' => '10', 'created_range(6i)' => '31',
                   'release' => 'embargo',
                   'embargo_date(1i)' => embargo_year, 'embargo_date(2i)' => '4', 'embargo_date(3i)' => '4',
                   'access' => 'stanford') # an access selection that will be overwritten
        end

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.contributors.size).to eq 2
          expect(work.contributors.last.full_name).to eq 'The Leland Stanford Junior University'
          expect(work.attached_files.size).to eq 2
          expect(work.keywords.size).to eq 2
          expect(work.related_works.size).to eq 2
          expect(work.related_links.size).to eq 2
          expect(work.citation).to eq 'test citation'
          expect(work.published_edtf.to_edtf).to eq '2020-02-14'
          expect(work.created_edtf.to_s).to eq '2020-03-04/2020-10-31'
          expect(work.embargo_date).to eq Date.parse("#{embargo_year}-04-04")
          expect(work.subtype).to eq ['Article', 'Presentation slides']
          expect(DepositJob).to have_received(:perform_later).with(work)
          expect(work.state).to eq 'depositing'
          expect(work.access).to eq 'world' # shows that `stanford` was overwritten
        end
      end

      context 'with a minimal set' do
        let(:collection) { create(:collection, :deposited, :depositor_selects_access, depositors: [user]) }
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            attached_files_attributes: files,
            contributors_attributes: contributors,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'immediate',
            access: 'stanford'
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('public/apple-touch-icon.png')),
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:contributors) do
          { '999' =>
            { '_destroy' => 'false', 'first_name' => '', 'last_name' => '',
              'full_name' => 'Stanford', 'role_term' => 'organization|Host institution' } }
        end

        let(:files) do
          {
            '0' => {
              '_destroy' => 'false',
              'label' => 'My ICO',
              'hide' => false,
              'file' => upload.signed_id
            }
          }
        end

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params, commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.contributors.size).to eq 1
          expect(work.attached_files.size).to eq 1
          expect(work.keywords.size).to eq 1
          expect(work.published_edtf).to be_nil
          expect(work.created_edtf).to be_nil
          expect(work.embargo_date).to be_nil
          expect(work.subtype).to be_empty
          expect(work.state).to eq 'depositing'
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with empty draft' do
        let(:collection) { create(:collection, :deposited, depositors: [user]) }
        let(:work_params) do
          {
            title: '',
            contact_email: '',
            abstract: '',
            license: License.license_list.first,
            work_type: 'text',
            release: 'immediate'
          }
        end

        it 'saves and then displays the draft work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Save as draft' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.title).to be_empty
          expect(work.contact_email).to be_empty
          expect(work.abstract).to be_empty
          expect(work.contributors).to be_empty
          expect(work.attached_files).to be_empty
          expect(work.keywords.size).to eq 0
          expect(work.published_edtf).to be_nil
          expect(work.created_edtf).to be_nil
          expect(work.embargo_date).to be_nil
          expect(work.subtype).to be_empty
          expect(work.license).to eq License.license_list.first
          expect(work.state).to eq 'first_draft'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'with automatic citation' do
        let(:collection) { create(:collection, :deposited, depositors: [user]) }
        let(:work_params) do
          {
            title: '',
            contact_email: '',
            abstract: '',
            license: License.license_list.first,
            work_type: 'text',
            release: 'immediate',
            citation: 'manual one',
            citation_auto: 'Zappa, F. (2020). Test publication yy/mm date in past. ' \
              'Stanford Digital Repository. Available at :link:',
            default_citation: true
          }
        end

        it 'saves and then displays the draft work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Save as draft' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.title).to be_empty
          expect(work.contact_email).to be_empty
          expect(work.abstract).to be_empty
          expect(work.contributors).to be_empty
          expect(work.attached_files).to be_empty
          expect(work.keywords.size).to eq 0
          expect(work.published_edtf).to be_nil
          expect(work.created_edtf).to be_nil
          expect(work.embargo_date).to be_nil
          expect(work.subtype).to be_empty
          expect(work.citation).to eq 'Zappa, F. (2020). Test publication yy/mm ' \
            'date in past. Stanford Digital Repository. Available at :link:'
          expect(work.license).to eq License.license_list.first
          expect(work.state).to eq 'first_draft'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'with a moderated collection' do
        let(:collection) { create(:collection, :with_reviewers, :deposited, depositors: [user]) }
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            contributors_attributes: contributors,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'immediate'
          }
        end

        let(:contributors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('public/apple-touch-icon.png')),
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:files) do
          {
            '0' => {
              '_destroy' => 'false',
              'label' => 'My ICO',
              'hide' => false,
              'file' => upload.signed_id
            }
          }
        end

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.contributors.size).to eq 1
          expect(work.attached_files.size).to eq 1
          expect(work.keywords.size).to eq 1
          expect(work.published_edtf).to be_nil
          expect(work.created_edtf).to be_nil
          expect(work.embargo_date).to be_nil
          expect(work.subtype).to be_empty
          expect(work.state).to eq 'pending_approval'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'with a collection with immediate release but a embargo is provided' do
        let(:collection) do
          create(:collection, :deposited, depositors: [user], release_option: 'immediate')
        end
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            contributors_attributes: contributors,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'embargo',
            'embargo(1i)': '2030',
            'embargo(2i)': '09',
            'embargo(3i)': '01'
          }
        end

        let(:contributors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('public/apple-touch-icon.png')),
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:files) do
          {
            '0' => {
              '_destroy' => 'false',
              'label' => 'My ICO',
              'hide' => false,
              'file' => upload.signed_id
            }
          }
        end

        it 'releases it immediately' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.embargo_date).to be_nil
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with a collection with delay release but a embargo is provided' do
        let(:collection) do
          create(:collection, :deposited, depositors: [user], release_option: 'delay', release_date: release_date)
        end
        let(:release_date) { Date.parse('2029-03-07') }
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            contributors_attributes: contributors,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'embargo',
            'embargo(1i)': '2030',
            'embargo(2i)': '09',
            'embargo(3i)': '01'
          }
        end

        let(:contributors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join('public/apple-touch-icon.png')),
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:files) do
          {
            '0' => {
              '_destroy' => 'false',
              'label' => 'My ICO',
              'hide' => false,
              'file' => upload.signed_id
            }
          }
        end

        it 'sets embargo to the date specified in the collection' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work = Work.last
          expect(work.embargo_date).to eq release_date
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with a collection that allows depositor to select embargo but missing embargo month and day' do
        let(:collection) do
          create(:collection, :deposited, depositors: [user], release_option: 'depositor-selects')
        end
        let(:work_params) do
          {
            title: 'A title of great import',
            contact_email: '',
            abstract: 'A work',
            license: License.license_list.first,
            work_type: 'text',
            release: 'embargo',
            'embargo(1i)': 2020,
            'embargo(2i)': '',
            'embargo(3i)': ''
          }
        end

        it 'returns an error' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include 'Must provide all parts'
        end
      end
    end
  end
end
