# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create a new work' do
  let(:work) { create(:work) }
  let(:collection) { collection_version.collection }
  let(:collection_version) { create(:collection_version_with_collection) }

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
      let(:collection_version) { create(:collection_version_with_collection, depositors: [user]) }

      it 'renders the form' do
        get "/collections/#{collection.id}/works/new?work_type=video"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include 'video'
      end
    end

    describe 'allowing content changes' do
      let(:alert_text) { 'Creating/Updating SDR content (i.e. collections or works) is not yet available.' }
      let(:collection_version) { create(:collection_version_with_collection, depositors: [user]) }

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

      context 'when a collection allows embargo and a license but restricts access and with all fields provided' do
        let(:collection) do
          create(:collection, depositors: [user], release_option: 'depositor-selects')
        end

        let(:authors) do
          { '0' =>
            { '_destroy' => '1', 'first_name' => 'Justin',
              'last_name' => 'Coyne', 'role_term' => 'person|Data collector' },
            '999' =>
            { '_destroy' => 'false', 'first_name' => 'Naomi', 'weight' => '1',
              'last_name' => 'Dushay', 'full_name' => 'Stanford', 'role_term' => 'person|Author' },
            '1002' =>
            { '_destroy' => 'false', 'first_name' => 'Naomi', 'weight' => '0',
              'last_name' => 'Dushay', 'full_name' => 'The Leland Stanford Junior University',
              'role_term' => 'organization|Host institution' } }
        end

        let(:upload1) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:upload2) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.root.join('spec/fixtures/files/favicon.ico').open,
            filename: 'favicon.ico',
            content_type: 'image/vnd.microsoft.icon'
          )
        end

        let(:upload3) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.root.join('spec/fixtures/files/sul.svg').open,
            filename: 'sul.svg',
            content_type: 'image/svg+xml'
          )
        end

        let(:contact_emails) do
          {
            '0' =>
            { '_destroy' => 'false', email: user.email },
            '999' =>
            { '_destroy' => 'false', email: 'contact_email@example.com' }
          }
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
          attributes_for(:work_version)
            .merge(authors_attributes: authors,
                   attached_files_attributes: files,
                   contact_emails_attributes: contact_emails,
                   keywords_attributes: keywords,
                   related_works_attributes: related_works,
                   related_links_attributes: related_links,
                   default_citation: false,
                   license: 'PDDL-1.0',
                   'published(1i)' => '2020', 'published(2i)' => '2', 'published(3i)' => '14',
                   created_type: 'range',
                   'created(1i)' => '2020', 'created(2i)' => '2', 'created(3i)' => '14',
                   'created_range(1i)' => '2020', 'created_range(2i)' => '3', 'created_range(3i)' => '4',
                   'created_range(4i)' => '2020', 'created_range(5i)' => '10', 'created_range(6i)' => '31',
                   'release' => 'embargo',
                   'embargo_date(1i)' => embargo_year, 'embargo_date(2i)' => '4', 'embargo_date(3i)' => '4',
                   access: 'stanford') # an access selection that will be overwritten
        end

        before { create(:collection_version_with_collection, collection:) }

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.authors.size).to eq 2
          expect(work_version.authors.first.full_name).to eq 'The Leland Stanford Junior University'
          expect(work_version.attached_files.size).to eq 2
          expect(work_version.contact_emails.size).to eq 2
          expect(work_version.keywords.size).to eq 2
          expect(work_version.related_works.size).to eq 2
          expect(work_version.related_links.size).to eq 2
          expect(work_version.citation).to eq 'test citation'
          expect(work_version.license).to eq 'PDDL-1.0'
          expect(work_version.published_edtf.to_edtf).to eq '2020-02-14'
          expect(work_version.created_edtf.to_s).to eq '2020-03-04/2020-10-31'
          expect(work_version.embargo_date).to eq Date.parse("#{embargo_year}-04-04")
          expect(work_version.subtype).to eq ['Code', 'Oral history']
          expect(DepositJob).to have_received(:perform_later).with(work_version)
          expect(work_version.state).to eq 'depositing'
          expect(work_version.access).to eq 'world' # shows that `stanford` was overwritten
        end
      end

      context 'when saving a draft that has an incomplete author' do
        let(:collection) do
          create(:collection, :depositor_selects_access, depositors: [user])
        end
        let(:params) do
          {
            'work' => {
              'work_type' => 'text',
              'title' => 'Test publication',
              'contact_emails_attributes' => { '0' => {
                'email' => 'foo@hotmail.com',
                '_destroy' => ''
              } },
              'authors_attributes' => { '0' => {
                'role_term' => 'person|Author',
                'with_orcid' => 'false',
                'first_name' => 'Camille ',
                'last_name' => '',
                'orcid' => '',
                'full_name' => '',
                '_destroy' => '',
                'weight' => '0'
              } },
              'contributors_attributes' => { '0' => {
                'role_term' => 'person|Author',
                'with_orcid' => 'false',
                'first_name' => '',
                'last_name' => '',
                'orcid' => '',
                'full_name' => '',
                '_destroy' => ''
              } },
              'published(1i)' => '',
              'published(2i)' => '',
              'published(3i)' => '',
              'created_type' => 'single',
              'created(1i)' => '',
              'created(2i)' => '',
              'created(3i)' => '',
              'abstract' => '',
              'keywords_attributes' => { '0' => {
                'label' => '',
                'uri' => '',
                'cocina_type' => '',
                '_destroy' => ''
              } },
              'default_citation' => 'true',
              'citation' => '',
              'citation_auto' => 'Zappa, F. (2020). Test publication yy/mm date in past. ' \
                                 'Stanford Digital Repository. Available at :link:',
              'related_works_attributes' => { '0' => {
                'citation' => '',
                '_destroy' => ''
              } },
              'related_links_attributes' => { '0' => {
                'link_title' => '',
                '_destroy' => '',
                'url' => ''
              } },
              'license' => 'CC-BY-NC-4.0',
              upload_type: 'browser'
            },
            'commit' => 'Save as draft',
            'controller' => 'works',
            'action' => 'create',
            'collection_id' => collection.id
          }
        end

        before { create(:collection_version_with_collection, collection:) }

        it 'saves the draft' do
          post "/collections/#{collection.id}/works", params: params
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.authors.size).to eq 1
        end
      end

      context 'with a minimal set' do
        let(:collection) do
          create(:collection, :depositor_selects_access, depositors: [user])
        end

        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_emails_attributes: contact_emails,
            abstract: 'test abstract',
            attached_files_attributes: files,
            authors_attributes: authors,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            upload_type: 'browser',
            release: 'immediate',
            access: 'stanford'
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
            filename: 'apple-touch-icon.png',
            content_type: 'image/png'
          )
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'first_name' => '', 'last_name' => '',
              'full_name' => 'Stanford', 'role_term' => 'organization|Host institution' } }
        end

        let(:contact_emails) do
          {
            '0' => {
              '_destroy' => false,
              'email' => 'test@example.com'
            }
          }
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

        before { create(:collection_version_with_collection, collection:) }

        it 'displays the work with all fields that changed in the event description' do
          post "/collections/#{collection.id}/works", params: { work: work_params, commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.authors.size).to eq 1
          expect(work_version.attached_files.size).to eq 1
          expect(work_version.keywords.size).to eq 1
          expect(work_version.contact_emails.size).to eq 1
          expect(work_version.published_edtf).to be_nil
          expect(work_version.created_edtf).to be_nil
          expect(work_version.embargo_date).to be_nil
          expect(work_version.subtype).to be_empty
          expect(work_version.state).to eq 'depositing'
          expect(DepositJob).to have_received(:perform_later)
          last_event = Work.last.events.last
          expect(last_event.event_type).to eq 'update_metadata'
          changes = ['title of deposit modified', 'abstract modified', 'contact email modified', 'authors modified',
                     'keywords modified', 'visibility modified', 'license modified', 'files added/removed',
                     'file description changed']
          expect(last_event.description).to eq changes.join(', ')
        end
      end

      context 'with empty draft' do
        let(:collection_version) { create(:collection_version_with_collection, depositors: [user]) }

        let(:work_params) do
          {
            title: '',
            abstract: '',
            license: License.license_list.first,
            work_type: 'text',
            upload_type: 'browser',
            release: 'immediate'
          }
        end

        it 'saves and then displays the draft work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Save as draft' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.title).to be_nil
          expect(work_version.contact_emails).to be_empty
          expect(work_version.abstract).to be_nil
          expect(work_version.authors).to be_empty
          expect(work_version.attached_files).to be_empty
          expect(work_version.keywords.size).to eq 0
          expect(work_version.published_edtf).to be_nil
          expect(work_version.created_edtf).to be_nil
          expect(work_version.embargo_date).to be_nil
          expect(work_version.subtype).to be_empty
          expect(work_version.license).to eq License.license_list.first
          expect(work_version.state).to eq 'first_draft'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'when event description changes' do
        let(:default_license) { 'CC0-1.0' }
        let(:collection) { create(:collection, depositors: [user], default_license:) }

        before { create(:collection_version_with_collection, collection:, depositors: [user]) }

        context 'with only title changed' do
          let(:title) { 'Added a title' }
          let(:work_params) do
            {
              title:,
              abstract: '',
              license: default_license,
              work_type: 'text',
              upload_type: 'browser',
              release: 'immediate'
            }
          end

          it 'saves the draft work with title modified for change description' do
            post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                  commit: 'Save as draft' }
            expect(response).to have_http_status(:found)
            work_version = Work.last.head
            expect(work_version.title).to eq title
            expect(work_version.license).to eq default_license
            last_event = Work.last.events.last
            expect(last_event.event_type).to eq 'update_metadata'
            expect(last_event.description).to eq 'title of deposit modified'
          end
        end

        context 'with default license selected' do
          let(:work_params) do
            {
              title: '',
              abstract: '',
              license: default_license,
              work_type: 'text',
              upload_type: 'browser',
              release: 'immediate'
            }
          end

          it 'saves the draft work with Created for change description' do
            post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                  commit: 'Save as draft' }
            expect(response).to have_http_status(:found)
            work_version = Work.last.head
            expect(work_version.license).to eq default_license
            last_event = Work.last.events.last
            expect(last_event.event_type).to eq 'update_metadata'
            expect(last_event.description).to eq 'Created'
          end
        end

        context 'with different license selected' do
          let(:license) { 'Apache-2.0' }
          let(:work_params) do
            {
              title: '',
              abstract: '',
              license:,
              upload_type: 'browser',
              work_type: 'text',
              release: 'immediate'
            }
          end

          it 'saves the draft work with license modified for change description' do
            post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                  commit: 'Save as draft' }
            expect(response).to have_http_status(:found)
            work_version = Work.last.head
            expect(work_version.license).to eq license
            last_event = Work.last.events.last
            expect(last_event.event_type).to eq 'update_metadata'
            expect(last_event.description).to eq 'license modified'
          end
        end
      end

      context 'with automatic citation' do
        let(:collection_version) { create(:collection_version_with_collection, depositors: [user]) }

        let(:work_params) do
          {
            title: '',
            abstract: '',
            license: License.license_list.first,
            upload_type: 'browser',
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
          work_version = Work.last.head
          expect(work_version.title).to be_nil
          expect(work_version.contact_emails).to be_empty
          expect(work_version.abstract).to be_nil
          expect(work_version.authors).to be_empty
          expect(work_version.attached_files).to be_empty
          expect(work_version.keywords.size).to eq 0
          expect(work_version.published_edtf).to be_nil
          expect(work_version.created_edtf).to be_nil
          expect(work_version.embargo_date).to be_nil
          expect(work_version.subtype).to be_empty
          expect(work_version.citation).to eq 'Zappa, F. (2020). Test publication yy/mm ' \
                                              'date in past. Stanford Digital Repository. Available at :link:'
          expect(work_version.license).to eq License.license_list.first
          expect(work_version.state).to eq 'first_draft'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'with a moderated collection' do
        let(:collection) { create(:collection, :with_reviewers, depositors: [user]) }
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            abstract: 'test abstract',
            authors_attributes: authors,
            contact_emails_attributes: contact_emails,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            upload_type: 'browser',
            release: 'immediate'
          }
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:contact_emails) do
          {
            '0' => {
              '_destroy' => false,
              'email' => 'test@example.com'
            }
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
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

        before { create(:collection_version_with_collection, collection:) }

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.authors.size).to eq 1
          expect(work_version.attached_files.size).to eq 1
          expect(work_version.contact_emails.size).to eq 1
          expect(work_version.keywords.size).to eq 1
          expect(work_version.published_edtf).to be_nil
          expect(work_version.created_edtf).to be_nil
          expect(work_version.embargo_date).to be_nil
          expect(work_version.subtype).to be_empty
          expect(work_version.state).to eq 'pending_approval'
          expect(DepositJob).not_to have_received(:perform_later)
        end
      end

      context 'with a collection with immediate release but a embargo is provided' do
        let(:collection) do
          create(:collection, depositors: [user], release_option: 'immediate')
        end
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            abstract: "test abstract\u0000", # bad unicode character will be stripped
            authors_attributes: authors,
            contact_emails_attributes: contact_emails,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            upload_type: 'browser',
            release: 'embargo',
            'embargo(1i)': '2030',
            'embargo(2i)': '09',
            'embargo(3i)': '01'
          }
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:contact_emails) do
          {
            '0' =>
            { '_destroy' => 'false', email: user.email },
            '999' =>
            { '_destroy' => 'false', email: 'contact_email@example.com' }
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
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

        before { create(:collection_version_with_collection, :with_contact_emails, collection:) }

        it 'releases it immediately' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.embargo_date).to be_nil
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with a collection with delay release but a embargo is provided' do
        let(:collection) do
          create(:collection, depositors: [user], release_option: 'delay', release_duration: '1 year')
        end
        let(:release_date) { Time.zone.today + 1.year }
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            abstract: 'test abstract',
            authors_attributes: authors,
            contact_emails_attributes: contact_emails,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            upload_type: 'browser',
            release: 'embargo'
          }
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:contact_emails) do
          {
            '0' =>
            { '_destroy' => 'false', email: user.email },
            '999' =>
            { '_destroy' => 'false', email: 'contact_email@example.com' }
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
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

        before { create(:collection_version_with_collection, :with_contact_emails, collection:) }

        it 'sets embargo to the date specified in the collection' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.embargo_date).to eq release_date
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with a collection that dictates a license but a license is provided' do
        let(:collection) do
          create(:collection, :with_required_license, depositors: [user])
        end
        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            abstract: 'test abstract',
            authors_attributes: authors,
            contact_emails_attributes: contact_emails,
            attached_files_attributes: files,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            upload_type: 'browser'
          }
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'full_name' => '', 'first_name' => 'Naomi',
              'last_name' => 'Dushay', 'role_term' => 'person|Author' } }
        end

        let(:contact_emails) do
          {
            '0' =>
            { '_destroy' => 'false', email: user.email },
            '999' =>
            { '_destroy' => 'false', email: 'contact_email@example.com' }
          }
        end

        let(:upload) do
          ActiveStorage::Blob.create_and_upload!(
            io: Rails.public_path.join('apple-touch-icon.png').open,
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

        before { create(:collection_version_with_collection, :with_contact_emails, collection:) }

        it 'sets the license indicated by the collection' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.license).to eq 'CC-BY-4.0'
          expect(DepositJob).to have_received(:perform_later)
        end
      end

      context 'with a partial create date range' do
        let(:collection_version) { create(:collection_version_with_collection, depositors: [user]) }

        let(:work_params) do
          {
            title: '',
            abstract: '',
            license: License.license_list.first,
            work_type: 'text',
            release: 'immediate',
            created_type: 'range',
            'created_range(1i)' => '2020', 'created_range(2i)' => '3', 'created_range(3i)' => '4',
            'created_range(4i)' => '', 'created_range(5i)' => '', 'created_range(6i)' => ''
          }
        end

        it 'displays the draft work with a validation error' do
          post "/collections/#{collection.id}/works", params: { work: work_params,
                                                                commit: 'Save as draft' }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include 'end must be provided'
        end
      end

      context 'with globus' do
        let(:collection) do
          create(:collection, :depositor_selects_access, depositors: [user])
        end

        let(:work_params) do
          {
            title: 'Test title',
            work_type: 'text',
            contact_emails_attributes: contact_emails,
            abstract: 'test abstract',
            attached_files_attributes: {},
            upload_type: 'globus',
            authors_attributes: authors,
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'immediate',
            access: 'stanford'
          }
        end

        let(:authors) do
          { '999' =>
            { '_destroy' => 'false', 'first_name' => '', 'last_name' => '',
              'full_name' => 'Stanford', 'role_term' => 'organization|Host institution' } }
        end

        let(:contact_emails) do
          {
            '0' => {
              '_destroy' => false,
              'email' => 'test@example.com'
            }
          }
        end

        before { create(:collection_version_with_collection, collection:) }

        it 'displays the work' do
          post "/collections/#{collection.id}/works", params: { work: work_params, commit: 'Deposit' }
          expect(response).to have_http_status(:found)
          work_version = Work.last.head
          expect(work_version.attached_files).to be_empty
          expect(work_version.globus?).to be true
          expect(work_version.upload_type).to eq 'globus'
          expect(work_version.state).to eq 'depositing'
        end
      end
    end
  end
end
