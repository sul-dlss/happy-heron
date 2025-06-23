# frozen_string_literal: true

# Duplicates a version, creating new related objects rather than point at objects for a past version.
# This is like NewCollectionVersionParameterFilter, but it works on objects instead of parameters.
class NewCollectionVersionService
  # @param [CollectionVersion] old_version
  # @return [CollectionVersion] the new version
  def self.dup(old_version, increment_version: false, save: false, version_description: nil, state: nil, &)
    new(old_version).dup(increment_version:, save:, version_description:, state:, &)
  end

  def initialize(old_version)
    @old_version = old_version
    # Dup does not copy associations.
    @new_version = old_version.dup
  end

  # rubocop:disable Metrics/AbcSize
  def dup(increment_version: false, save: false, version_description: nil, state: nil)
    associations_to_filter.each do |relation|
      dup_relation(relation)
    end

    new_version.version = old_version.version + 1 if increment_version
    new_version.version_description = version_description if version_description
    new_version.state = state if state
    yield new_version if block_given?
    perform_save if save

    new_version
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :old_version, :new_version

  def dup_relation(relation)
    old_version.public_send(relation).each do |existing_relation|
      new_relation = existing_relation.dup
      new_version.public_send(relation) << new_relation
    end
  end

  def associations_to_filter
    CollectionVersion.aggregate_associations
  end

  def perform_save
    collection = old_version.collection
    collection.transaction do
      old_version.save!
      collection.head = new_version
      collection.save!
    end
  end
end
