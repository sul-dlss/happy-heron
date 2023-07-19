# frozen_string_literal: true

# Determines whether a work can be moved to a collection.
class CheckMoveWorkService
  # @return [Array<String>] list of errors, empty if can be moved
  def self.check(work:, collection:)
    new(work:, collection:).check
  end

  def initialize(work:, collection:)
    @work = work
    @collection = collection
  end

  # rubocop:disable Metrics/AbcSize
  def check
    [].tap do |errors|
      errors << "Collection has not been deposited." unless collection.druid
      errors << "Collection is the same as the current collection." if collection.id == work.collection_id
      errors << "Item is embargoed but the collection is set for immediate release only." unless compatible_release?
      if missing_doi?
        errors << "Depositor of the item chose not to get a DOI but the collection requires DOI assignment."
      end
      errors << "Item has a license that is not allowed by the collection setting." unless compatible_license?
      unless compatible_access?
        errors << "Item is set for Stanford visibility but the collection requires world visibility."
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :work, :collection

  def compatible_release?
    !work.embargoed? || collection.release_option != "immediate"
  end

  def missing_doi?
    !work.assign_doi && collection.doi_option == "yes"
  end

  def compatible_license?
    return true if collection.license_option != "required"

    work.head.license == collection.required_license
  end

  def compatible_access?
    work.head.access != "stanford" || collection.access != "world"
  end
end
