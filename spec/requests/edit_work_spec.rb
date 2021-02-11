# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating an existing work' do
  let(:work) { work_version.work }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
    work.update(head: work_version)
  end

  context 'with an authenticated user' do
    let(:user) { work.depositor }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    describe 'display the form' do
      let(:work_version) { create(:work_version, :published, :with_creation_date_range) }

      it 'shows the form' do
        get "/works/#{work.id}/edit"
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'submit the form' do
      context 'when the previous version was deposited' do
        let(:work_version) { create(:work_version, :deposited, :with_required_associations) }
        let(:user) { work.depositor }
        let(:work_params) do
          {
            title: 'New title',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            attached_files_attributes: {
              '0' => { 'label' => 'two', '_destroy' => '', 'hide' => '0', 'id' => work_version.attached_files.first.id }
            },
            keywords_attributes: {},
            authors_attributes: {},
            contact_emails_attributes: {},
            license: 'CC0-1.0',
            release: 'immediate'
          }.tap do |param|
            work_version.keywords.each_with_object(param[:keywords_attributes]).with_index do |(keyword, attrs), index|
              attrs[index.to_s] =
                { '_destroy' => 'false', 'id' => keyword.id, 'label' => 'Feminism',
                  'uri' => 'http://id.worldcat.org/fast/922671' }
            end

            work_version.authors.each_with_object(param[:authors_attributes]).with_index do |(author, attrs), index|
              attrs[index.to_s] =
                { '_destroy' => 'false', 'id' => author.id, 'role_term' => 'person|Author', 'first_name' => 'Justin',
                  'last_name' => 'Coyne', 'full_name' => '' }
            end

            work_version.contact_emails.each_with_object(param[:contact_emails_attributes])
                        .with_index do |(author, attrs), index|
              attrs[index.to_s] = { '_destroy' => 'false', 'id' => author.id, 'email' => 'bob@foo.io' }
            end
          end
        end

        before do
          create(:attached_file, :with_file, work_version: work_version)
          allow(CollectionObserver).to receive(:collection_activity)
        end

        it 'redirects to the work page' do
          patch "/works/#{work.id}", params: { work: work_params }
          expect(CollectionObserver).to have_received(:collection_activity)
          expect(WorkVersion.where(work: work).count).to eq 2
          expect(work.reload.head).to be_version_draft
          expect(response).to redirect_to(work)
        end
      end

      context 'with a validation problem' do
        let(:work) { work_version.work }
        let(:work_version) { create(:work_version) }
        let(:user) { work.depositor }
        let(:work_params) do
          {
            title: '',
            work_type: 'text',
            contact_email: 'io@io.io',
            abstract: 'test abstract',
            keywords_attributes: {
              '0' => { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' }
            },
            license: 'CC0-1.0',
            release: 'immediate'
          }
        end

        it 'returns a validation error' do
          patch "/works/#{work.id}", params: { work: work_params, commit: 'Deposit' }
          expect(response).to have_http_status :unprocessable_entity
          expect(response.body).to include 'Title can&#39;t be blank'
          expect(response.body).to include 'Please add at least one file.'
        end
      end
    end
  end
end
