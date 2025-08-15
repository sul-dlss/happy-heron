# frozen_string_literal: true

module Admin
  # Converts a set of works to CSV.
  class SunetidCsvGenerator
    def self.generate(works)
      new(works).generate
    end

    def initialize(works)
      @works = works
    end

    def generate
      CSV.generate do |csv|
        csv << HEADERS
        works.each do |work|
          csv << row(work)
        end
      end
    end

    private

    attr_reader :works

    HEADERS = [
      'druid',
      'depositor sunetid'
    ].freeze

    def row(work)
      return [work, 'sunetid not found'] unless work.is_a?(Work)

      [
        work.druid,
        work.depositor.sunetid
      ]
    end
  end
end
