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
      'depositor sunetid'
    ].freeze

    def row(work)
      [
        work.druid,
        work.depositor.sunetid
      ]
    end
  end
end
