# frozen_string_literal: true

module Admin
  # Converts a set of works to CSV.
  class SunetidCsvGenerator
    def self.generate(relation)
      new(relation).generate
    end

    def initialize(relation)
      @relation = relation
    end

    def generate
      CSV.generate do |csv|
        csv << HEADERS
        relation.each do |work|
          csv << row(work)
        end
      end
    end

    private

    attr_reader :relation

    HEADERS = [
      'druid',
      'depositor'
    ].freeze

    # rubocop:disable Metrics/AbcSize
    def row(work)
      version = work.head
      collection = work.collection

      [
        work.druid_without_namespace,
        work.depositor.sunetid
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
