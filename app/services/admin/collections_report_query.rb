# frozen_string_literal: true

module Admin
  # Generates a query for Collections
  class CollectionsReportQuery
    # @param [Admin::CollectionsReport] collections_report
    # @return [ActiveRecord::Relation]
    def self.generate(collections_report)
      new(collections_report).generate
    end

    def initialize(collections_report)
      @collections_report = collections_report
    end

    def generate
      self.query = Collection.joins(:head, :creator)
      add_status_filter
      add_date_created_start_filter
      add_date_created_end_filter
      add_date_modified_start_filter
      add_date_modified_end_filter
      query.order('collection_versions.name ASC')
    end

    private

    attr_reader :collections_report
    attr_accessor :query

    def add_status_filter
      return if collections_report.statuses.empty?

      self.query = query.where(collection_versions: { state: collections_report.statuses })
    end

    def add_date_created_start_filter
      return unless collections_report.date_created_start

      self.query = query.where('collections.created_at >= ?',
                               collections_report.date_created_start)
    end

    def add_date_created_end_filter
      return unless collections_report.date_created_end

      self.query = query.where('collections.created_at <= ?',
                               collections_report.date_created_end)
    end

    def add_date_modified_start_filter
      return unless collections_report.date_modified_start

      self.query = query.where('collection_versions.updated_at >= ?',
                               collections_report.date_modified_start)
    end

    def add_date_modified_end_filter
      return unless collections_report.date_modified_end

      self.query = query.where('collection_versions.updated_at <= ?',
                               collections_report.date_modified_end)
    end
  end
end
