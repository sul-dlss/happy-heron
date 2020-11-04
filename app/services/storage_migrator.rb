# typed: strict
# frozen_string_literal: true

# Move files into druid-based storage location
class StorageMigrator
  extend T::Sig

  sig { params(druid: String, source: ActiveStorage::Service, target: ActiveStorage::Service).returns(T::Boolean) }
  def self.migrate(druid:, source: default_source, target: default_target)
    new(druid: druid, source: source, target: target).migrate
  end

  sig { returns(ActiveStorage::Service) }
  def self.default_source
    ActiveStorage::Service.configure(:local, active_storage_configs)
  end
  private_class_method :default_source

  sig { returns(ActiveStorage::Service) }
  def self.default_target
    ActiveStorage::Service.configure(:druid, active_storage_configs)
  end
  private_class_method :default_target

  sig { returns(T::Hash[String, T::Hash[String, String]]) }
  def self.active_storage_configs
    # Need to load ActiveStorage::Blob to force the service configurations to load
    ActiveStorage::Blob.connection
    Rails.configuration.active_storage.service_configurations
  end
  private_class_method :active_storage_configs

  sig { params(druid: String, source: ActiveStorage::Service, target: ActiveStorage::Service).void }
  def initialize(druid:, source:, target:)
    @druid = druid
    @source = source
    @target = target
  end

  sig { returns(T::Boolean) }
  def migrate
    # Retrieve blobs from source service
    ActiveStorage::Blob.service = source

    if attached_files.empty?
      Rails.logger.info "No files to migrate for deposited work (#{druid})"
      return false
    end

    attached_files.each do |af|
      Rails.logger.info "Migrating #{af.filename} blob to druid disk location for deposited work #{druid}"

      # Wrap in transaction so that source delete does not happen if target upload fails
      ActiveRecord::Base.transaction do
        af.blob.open do |blob|
          # ActiveStorage does checksum checking for us
          target.upload(af.blob.key, blob, checksum: af.blob.checksum)
          source.delete(af.blob.key)
        end
      end
    end

    true
  end

  private

  sig { returns(String) }
  attr_reader :druid

  sig { returns(ActiveStorage::Service) }
  attr_reader :source

  sig { returns(ActiveStorage::Service) }
  attr_reader :target

  sig { returns(ActiveRecord::Relation) }
  def attached_files
    work = Work.find_by(druid: druid)
    return AttachedFile.none if work.nil?

    work.attached_files
  end
end
