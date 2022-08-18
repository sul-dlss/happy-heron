# frozen_string_literal: true

module Admin
  # Generates collection reports
  class CollectionReportsController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def new
      authorize! :collection_report

      if params[:commit]
        generate_report
      else
        @collections_report = CollectionsReport.new
        @collection_results = nil
      end
    end

    def create
      authorize! :collection_report
      generate_report
      send_data generate_csv,
                filename: 'collections_report.csv',
                type: 'text/csv', disposition: 'attachment'
    end

    private

    def generate_report
      @collections_report = CollectionsReport.new(collections_report_params)
      @collection_results = Admin::CollectionsReportQuery.generate(@collections_report)
    end

    def generate_csv
      Admin::CollectionsCsvGenerator.generate(@collection_results)
    end

    def collections_report_params
      params.require(:admin_collections_report).permit(:status_first_draft, :status_version_draft,
                                                       :status_deposited, :date_created_start, :date_created_end,
                                                       :date_modified_start, :date_modified_end)
    end
  end
end
