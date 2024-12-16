# frozen_string_literal: true

module Admin
  # Produce a report of SUNETIDs associated with the provided list of druids
  class SunetidReportsController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def new
      authorize!

      if params[:commit]
        generate_report
      else
        @report = SunetidReport.new
        @results = nil
      end
    end

    def create
      authorize!
      generate_report
      send_data generate_csv,
                filename: 'sunet_report.csv',
                type: 'text/csv', disposition: 'attachment'
    end

    private

    def generate_report
      @report = SunetidReport.new(druids: report_params[:druids])
      @results = Admin::SunetidReportQuery.generate(@report)
    end

    def generate_csv
      Admin::SunetidCsvGenerator.generate(@results)
    end

    def report_params
      params.require(:sunetid_report).permit(:druids)
    end
  end
end
