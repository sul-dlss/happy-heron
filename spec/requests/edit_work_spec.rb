# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Updating an existing work" do
  let(:work) { work_version.work }

  before do
    allow(Settings).to receive(:allow_sdr_content_changes).and_return(true)
    work.update(head: work_version)
    allow(Repository).to receive(:valid_version?).and_return(true)
  end

  context "with an authenticated user" do
    let(:user) { work.owner }

    before do
      sign_in user, groups: ["dlss:hydrus-app-collection-creators"]
    end

    describe "display the form" do
      let(:collection) { create(:collection_version_with_collection).collection }
      let(:work) { create(:work, collection:, druid: "druid:bb408qn5061") }
      let(:work_version) { create(:work_version, :published, :with_creation_date_range, work:) }

      context "when a valid version" do
        it "shows the form" do
          get "/works/#{work.id}/edit"
          expect(response).to have_http_status(:ok)
          expect(response.body).to match(%r{<title>SDR \| MyString \| Test title \d+</title>})
        end
      end

      context "when an invalid version" do
        before do
          allow(Repository).to receive(:valid_version?).and_return(false)
        end

        it "alerts and does not show the form" do
          expect { get "/works/#{work.id}/edit" }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
            "WorksMailer", "version_mismatch_email", "deliver_now",
            {params: {work:}, args: []}
          )
          expect(response).to redirect_to(dashboard_path)
        end
      end
    end

    describe "submit the form" do
      context "when the previous version was deposited" do
        let(:collection) { create(:collection_version_with_collection).collection }
        let(:work) { create(:work, collection:) }
        let(:work_version) { create(:work_version, :deposited, :with_required_associations, work:) }
        let(:work_params) do
          {
            title: "New title",
            work_type: "text",
            abstract: "test abstract",
            upload_type:,
            globus_origin:,
            fetch_globus_files:,
            attached_files_attributes: {
              "0" => {"label" => "two", "_destroy" => "", "hide" => "0", "id" => work_version.attached_files.first.id}
            },
            keywords_attributes: {},
            authors_attributes: {},
            contact_emails_attributes: {},
            license: "CC0-1.0",
            release: "immediate"
          }.tap do |param|
            # Keywords aren't changing.
            work_version.keywords.each_with_object(param[:keywords_attributes]).with_index do |(keyword, attrs), index|
              attrs[index.to_s] =
                {"_destroy" => "", "id" => keyword.id, "label" => keyword.label,
                 "uri" => keyword.uri}
            end

            work_version.authors.each_with_object(param[:authors_attributes]).with_index do |(author, attrs), index|
              attrs[index.to_s] =
                {"_destroy" => "false", "id" => author.id, "role" => "Author", "contributor_type" => "person",
                 "first_name" => "Justin", "last_name" => "Coyne", "full_name" => ""}
            end

            work_version.contact_emails.each_with_object(param[:contact_emails_attributes])
              .with_index do |(author, attrs), index|
              attrs[index.to_s] = {"_destroy" => "false", "id" => author.id, "email" => "bob@foo.io"}
            end
          end
        end

        let(:upload_type) { "browser" }
        let(:fetch_globus_files) { "false" }
        let(:globus_origin) { "" }

        before do
          create(:attached_file, :with_file, work_version:)
          allow(CollectionObserver).to receive(:version_draft_created)
        end

        context "when starting a new version draft" do
          it "redirects to the work page" do
            patch "/works/#{work.id}", params: {work: work_params}
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work:).count).to eq 2
            expect(work.reload.head).to be_version_draft
            expect(work.head.subtype).to eq []
            # Only changed fields are recorded in event.
            expect(work.events.first.description).to eq("title of deposit modified, contact email modified, " \
                                                        "authors modified, work subtypes modified, " \
                                                        "file description changed")
            expect(response).to redirect_to(work)
          end
        end

        context "when a doi is requested (but wasn't present before)" do
          let(:work) { create(:work, :with_druid, collection:) }

          before do
            work_params[:assign_doi] = "true"
            collection.update!(doi_option: "depositor-selects")
          end

          it "sets the doi" do
            patch "/works/#{work.id}", params: {work: work_params, commit: "Deposit"}
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work:).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.doi).to eq "10.80343/bc123df4567"
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end

        context "when a doi is not requested (and wasn't present before)" do
          let(:work) { create(:work, :with_druid, collection:) }

          before do
            work_params[:assign_doi] = "false"
            collection.update!(doi_option: "depositor-selects")
          end

          it "does not set the doi" do
            patch "/works/#{work.id}", params: {work: work_params, commit: "Deposit"}
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work:).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.doi).to be_nil
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end

        context "when a doi is not permitted" do
          let(:work) { create(:work, :with_druid, collection:) }

          before do
            collection.update!(doi_option: "no")
          end

          it "sets assign_doi to false" do
            patch "/works/#{work.id}", params: {work: work_params, commit: "Deposit"}
            expect(CollectionObserver).to have_received(:version_draft_created)
            expect(WorkVersion.where(work:).count).to eq 2
            expect(work.reload.head).to be_depositing
            expect(work.assign_doi).to be false
            expect(response).to redirect_to(next_step_work_path(work))
          end
        end

        context "with a Globus upload type" do
          before do
            allow(GlobusClient).to receive(:has_files?).and_return(true)
            allow(FetchGlobusJob).to receive(:perform_later)
          end

          let(:work_version) { create(:work_version, :version_draft, :with_required_associations, work:) }
          let(:upload_type) { "globus" }
          let(:fetch_globus_files) { "true" }
          let(:globus_origin) { "oak" }

          context "when saving draft" do
            it "redirects to the work page and starts fetching globus" do
              patch "/works/#{work.id}", params: {work: work_params, commit: "Save as draft"}
              expect(work.reload.head).to be_fetch_globus_version_draft
              expect(work.head).to be_oak
              expect(response).to redirect_to(work)
              expect(FetchGlobusJob).to have_received(:perform_later).with(work_version)
            end
          end

          context "when depositing" do
            it "redirects to next_step page and starts fetching globus" do
              patch "/works/#{work.id}", params: {work: work_params, commit: "Deposit"}
              expect(work.reload.head).to be_fetch_globus_depositing
              expect(response).to redirect_to(next_step_work_path(work))
            end
          end
        end

        context "with a zipfile upload type" do
          before do
            allow(UnzipJob).to receive(:perform_later)
          end

          let(:work_version) { create(:work_version, :version_draft, :with_required_associations, work:) }
          let(:upload_type) { "zipfile" }

          context "when saving draft" do
            it "redirects to the work page and starts unzipping the file" do
              patch "/works/#{work.id}", params: {work: work_params, commit: "Save as draft"}
              expect(work.reload.head).to be_unzip_version_draft
              expect(response).to redirect_to(work)
              expect(UnzipJob).to have_received(:perform_later).with(work_version)
            end
          end
        end
      end

      context "with a validation problem" do
        let(:collection) { create(:collection_version_with_collection).collection }
        let(:work) { create(:work, collection:) }
        let(:work_version) { create(:work_version, work:) }

        context "when missing title" do
          let(:work_params) do
            {
              title: "",
              work_type: "text",
              abstract: "test abstract",
              keywords_attributes: {
                "0" => {"_destroy" => "false", "label" => "Feminism", "uri" => "http://id.worldcat.org/fast/922671"}
              },
              license: "CC0-1.0",
              release: "immediate"
            }
          end

          it "returns a validation error" do
            patch "/works/#{work.id}", params: {work: work_params, commit: "Deposit"}
            expect(response).to have_http_status :unprocessable_entity
            expect(response.body).to include "Title can&#39;t be blank"
            expect(response.body).to include "Please add at least one file."
          end
        end
      end

      context "when duplicate keywords" do
        let(:keyword) { {"_destroy" => "false", "label" => "Feminism", "uri" => "http://id.worldcat.org/fast/922671"} }
        let(:collection) { create(:collection_version_with_collection).collection }
        let(:work) { create(:work, collection:) }
        let(:work_version) { create(:work_version, work:) }
        let(:work_params) do
          {
            title: "This is a title",
            work_type: "text",
            abstract: "test abstract",
            keywords_attributes: {
              "0" => keyword,
              "1" => keyword
            },
            license: "CC0-1.0",
            release: "immediate"
          }
        end

        context "when saved as draft" do
          it "removes the duplicate keyword without error" do
            patch "/works/#{work.id}", params: {work: work_params, commit: "Save as draft"}
            expect(response).to have_http_status(:found)
            expect(work_version.keywords.size).to eq 1
          end
        end
      end
    end
  end
end
