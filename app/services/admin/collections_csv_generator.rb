# frozen_string_literal: true

require 'csv'

module Admin
  # Converts a set of collections to CSV.
  class CollectionsCsvGenerator
    def self.generate(collections)
      new(collections).generate
    end

    def initialize(collections)
      @collections = collections
    end

    def generate
      CSV.generate do |csv|
        csv << HEADERS
        collections.each do |collection|
          csv << row(collection)
        end
      end
    end

    private

    attr_reader :collections

    HEADERS = [
      'collection title',
      'collection id',
      'collection druid',
      'state',
      'version number',
      'creator',
      'managers',
      'date created',
      'date last modified',
      'release setting',
      'release duration',
      'visibility setting',
      'license setting',
      'required license',
      'default license',
      'DOI yes/no',
      'review workflow'
    ].freeze

    # rubocop:disable Metrics/AbcSize
    def row(collection)
      collection_version = collection.head
      [
        collection_version.name,
        collection.id,
        collection.druid_without_namespace,
        collection_version.state,
        collection_version.version,
        collection.creator.sunetid,
        collection.managed_by.map(&:sunetid).join('; '),
        collection.created_at,
        collection_version.updated_at,
        collection.release_option,
        collection.release_duration,
        collection.access,
        collection.license_option,
        collection.required_license,
        collection.default_license,
        collection.doi_option,
        collection.review_enabled
      ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
