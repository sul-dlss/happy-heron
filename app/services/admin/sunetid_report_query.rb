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
    end

    def generate
      self.query = Work.where(druid: report.druids)
                       .joins(:head, :owner)
      query.order('users.email ASC')
    end

    private

    attr_reader :report
    attr_accessor :query

  end
end
