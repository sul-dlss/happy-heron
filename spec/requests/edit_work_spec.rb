# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Updating an existing work' do
  let(:work) { work_version.work }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
    work.update(head: work_version)
  end

  context 'with an authenticated user' do
    let(:user) { work.owner }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    describe 'display the form' do
      let(:collection) { create(:collection_version_with_collection).collection }
      let(:work) { create(:work, collection: collection) }
      let(:work_version) { create(:work_version, :published, :with_creation_date_range, work: work) }

      it 'shows the form' do
        get "/works/#{work.id}/edit"
        expect(response).to have_http_status(:ok)
        expect(response.body).to match(%r{<title>SDR \| MyString \| Test title \d+</title>})
      end
    end

    describe 'submit the form' do
      context 'when the previous version was deposited' do
        let(:collection) { create(:collection_version_with_collection).collection }
        let(:work) { create(:work, collection: collection) }
        let(:work_version) { create(:work_version, :deposited, :with_required_associations, work: work) }
        let(:work_params) do
          {
            title: 'New title',
            work_type: 'text',
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
            # Keywords aren't changing.
            work_version.keywords.each_with_object(param[:keywords_attributes]).with_index do |(keyword, attrs), index|
              attrs[index.to_s] =
                { '_destroy' => '', 'id' => keyword.id, 'label' => keyword.label,
                  'uri' => keyword.uri }
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
          allow(CollectionObserver).to receive(:version_draft_created)
        end

        context 'when starting a new version draft' do
          it 'redirects to the work page' do
            patch "/works/#{work.id}", params: { work: work_params }
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work: work).count).to eq 2
            expect(work.reload.head).to be_version_draft
            # Only changed fields are recorded in event.
            expect(work.events.first.description).to eq('title of deposit modified, contact email modified, ' \
                                                        'authors modified, file description changed')
            expect(response).to redirect_to(work)
          end
        end

        context "when a doi is requested (but wasn't present before)" do
          let(:work) { create(:work, :with_druid, collection: collection) }

          before do
            work_params[:assign_doi] = 'true'
            collection.update!(doi_option: 'depositor-selects')
          end

          it 'sets the doi' do
            patch "/works/#{work.id}", params: { work: work_params, commit: 'Deposit' }
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work: work).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.doi).to eq '10.80343/bc123df4567'
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end

        context "when a doi is not requested (and wasn't present before)" do
          let(:work) { create(:work, :with_druid, collection: collection) }

          before do
            work_params[:assign_doi] = 'false'
            collection.update!(doi_option: 'depositor-selects')
          end

          it 'sets the doi' do
            patch "/works/#{work.id}", params: { work: work_params, commit: 'Deposit' }
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work: work).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.doi).to be_nil
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end

        context 'when a doi is not permitted' do
          let(:work) { create(:work, :with_druid, collection: collection) }

          before do
            collection.update!(doi_option: 'no')
          end

          it 'sets assign_doi to false' do
            patch "/works/#{work.id}", params: { work: work_params, commit: 'Deposit' }
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work: work).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.assign_doi).to be false
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end
      end

      context 'with a validation problem' do
        let(:collection) { create(:collection_version_with_collection).collection }
        let(:work) { create(:work, collection: collection) }
        let(:work_version) { create(:work_version, work: work) }

        context 'when missing title' do
          let(:work_params) do
            {
              title: '',
              work_type: 'text',
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

        context 'when duplicate keywords' do
          let(:keyword) { { '_destroy' => 'false', 'label' => 'Feminism', 'uri' => 'http://id.worldcat.org/fast/922671' } }
          let(:work_params) do
            {
              title: 'This is a title',
              work_type: 'text',
              abstract: 'test abstract',
              keywords_attributes: {
                '0' => keyword,
                '1' => keyword
              },
              license: 'CC0-1.0',
              release: 'immediate'
            }
          end

          it 'returns a validation error' do
            patch "/works/#{work.id}", params: { work: work_params, commit: 'Deposit' }
            expect(response).to have_http_status :unprocessable_entity
            expect(response.body).to include 'Please ensure all keywords are unique'
          end
        end
      end
    end
  end
end
