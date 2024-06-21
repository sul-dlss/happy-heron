# frozen_string_literal: true

module Admin
  # Converts a set of works to CSV.
  class WorkCsvGenerator
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
      'item title',
      'work id',
      'druid',
      'state',
      'version number',
      'depositor',
      'owner',
      'date created',
      'date last modified',
      'date last deposited',
      'release',
      'visibility',
      'license',
      'custom rights',
      'DOI',
      'collection title',
      'collection id',
      'collection druid'
    ].freeze

    # rubocop:disable Metrics/AbcSize
    def row(work)
      version = work.head
      collection = work.collection

      [
        version.title,
        work.id,
        work.druid_without_namespace,
        version.state,
        version.version,
        work.depositor.sunetid,
        work.owner.sunetid,
        work.created_at,
        version.updated_at,
        version.published_at,
        version.embargo_date || 'immediate',
        version.access,
        version.license,
        version.custom_rights ? 'yes' : 'no',
        work.doi,
        collection.head.name,
        collection.id,
        collection.druid_without_namespace
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
