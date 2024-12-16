# frozen_string_literal: true

module Admin
  # Generates a query for SUNETids by druid
  class SunetidReportQuery
    # @param [SunetidReport] report
    # @return [ActiveRecord::Relation]
    def self.generate(report)
      new(report).generate
    end

    def initialize(report)
      @report = report
      report.druids.map! { |druid| druid.start_with?('druid:') ? druid : "druid:#{druid}" }
    end

    def generate
      self.query = Work.where(druid: report.druids).joins(:depositor)
      query.order('users.email ASC, works.druid ASC')
    end

    private

    attr_reader :report
    attr_accessor :query
  end
end
