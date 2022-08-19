# frozen_string_literal: true

module Admin
  # Generates a query for Works
  class WorkReportQuery
    # @param [WorkReport] report
    # @return [ActiveRecord::Relation]
    def self.generate(report)
      new(report).generate
    end

    def initialize(report)
      @report = report
    end

    def generate
      self.query = Work.joins(:head, :owner)
      add_status_filter
      add_collection_filter
      add_date_created_start_filter
      add_date_created_end_filter
      add_date_modified_start_filter
      add_date_modified_end_filter
      add_date_deposited_start_filter
      add_date_deposited_end_filter
      query.order('users.email ASC')
    end

    private

    attr_reader :report
    attr_accessor :query

    def add_status_filter
      state = report.state.compact_blank
      return if state.empty?

      self.query = query.where(head: { state: state })
    end

    def add_collection_filter
      return if report.collection_id.blank?

      self.query = query.where(collection_id: report.collection_id)
    end

    def add_date_created_start_filter
      return unless report.date_created_start

      self.query = query.where('works.created_at >= ?',
                               report.date_created_start)
    end

    def add_date_created_end_filter
      return unless report.date_created_end

      self.query = query.where('works.created_at <= ?',
                               report.date_created_end)
    end

    def add_date_modified_start_filter
      return unless report.date_modified_start

      self.query = query.where('work_versions.updated_at >= ?',
                               report.date_modified_start)
    end

    def add_date_modified_end_filter
      return unless report.date_modified_end

      self.query = query.where('work_versions.updated_at <= ?',
                               report.date_modified_end)
    end

    def add_date_deposited_start_filter
      return unless report.date_deposited_start

      self.query = query.where('work_versions.published_at >= ?',
                               report.date_deposited_start)
    end

    def add_date_deposited_end_filter
      return unless report.date_deposited_end

      self.query = query.where('work_versions.published_at <= ?',
                               report.date_deposited_end)
    end
  end
end
