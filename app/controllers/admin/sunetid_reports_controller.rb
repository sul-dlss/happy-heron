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
      @report = SunetidReport.new(druids: druids_with_prefix(report_params[:druids]))
      @results = Admin::SunetidReportQuery.generate(@report)
    end

    def generate_csv
      Admin::SunetidCsvGenerator.generate([@results.to_a, missing_druids].flatten)
    end

    def report_params
      params.require(:sunetid_report).permit(:druids)
    end

    def druids_with_prefix
      return [] if report_params[:druids].blank?

      report_params[:druids].split("\n").map { |druid| druid.start_with?('druid:') ? druid : "druid:#{druid}" }.map(&:strip)
    end

    def missing_druids
      @missing_druids ||= druids_with_prefix - @results.pluck(:druid)
    end
  end
end
