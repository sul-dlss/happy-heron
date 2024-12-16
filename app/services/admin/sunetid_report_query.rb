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
      @druids = prefixed_druids(report.druids)
    end

    def generate
      self.query = Work.where(druid: druids).joins(:depositor)
      query.order('users.email ASC, works.druid ASC')
    end

    private

    attr_reader :report, :druids
    attr_accessor :query

    def prefixed_druids(druids)
      return [] if druids.blank?

      druids.split("\n").map { |druid| druid.start_with?('druid:') ? druid : "druid:#{druid}" }.map(&:strip)
    end
  end
end
