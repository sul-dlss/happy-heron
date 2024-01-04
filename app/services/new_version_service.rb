# frozen_string_literal: true

# Duplicates a version, creating new related objects rather than point at objects for a past version.
# This is like NewVersionParameter, but it works on objects instead of parameters.
class NewVersionService
  # @param [WorkVersion] old_version
  # @return [WorkVersion] the new version
  def self.dup(old_version, increment_version: false, save: false, version_description: nil, state: nil, &block)
    new(old_version).dup(increment_version:, save:, version_description:, state:, &block)
  end

  def initialize(old_version)
    @old_version = old_version
    # Dup does not copy associations.
    @new_version = old_version.dup
  end

  # rubocop:disable Metrics/AbcSize
  def dup(increment_version: false, save: false, version_description: nil, state: nil)
    dup_attached_files
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

  def dup_attached_files
    old_version.attached_files.each do |existing_attached_file|
      new_version.attached_files << dup_attached_file(existing_attached_file)
    end
  end

  def dup_attached_file(existing_attached_file)
    new_attached_file = existing_attached_file.dup
    new_attached_file.file.attach(existing_attached_file.file.blob.signed_id)
    new_attached_file
  end

  def dup_relation(relation)
    old_version.public_send(relation).each do |existing_relation|
      new_relation = existing_relation.dup
      new_version.public_send(relation) << new_relation
    end
  end

  def associations_to_filter
    WorkVersion.aggregate_associations - [:attached_files]
  end

  def perform_save
    work = old_version.work
    work.transaction do
      new_version.save!
      work.update!(head_id: new_version.id)
    end
  end
end
