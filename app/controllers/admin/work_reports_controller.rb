# frozen_string_literal: true

module Admin
  # Generates work reports
  class WorkReportsController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def new
      authorize!

      if params[:commit]
        generate_report
      else
        @report = WorkReport.new
        @results = nil
      end
    end

    def create
      authorize!
      generate_report
      send_data generate_csv,
                filename: 'item_report.csv',
                type: 'text/csv', disposition: 'attachment'
    end

    private

    def generate_report
      @report = WorkReport.new(report_params)
      @results = Admin::WorkReportQuery.generate(@report)
    end

    def generate_csv
      Admin::WorkCsvGenerator.generate(@results)
    end

    def report_params
      params.require(:work_report).permit(:date_created_start, :date_created_end,
                                          :date_modified_start, :date_modified_end,
                                          :date_deposited_start, :date_deposited_end,
                                          :collection_id, state: [])
    end
  end
end
