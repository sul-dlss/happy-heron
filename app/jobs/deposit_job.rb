# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < ApplicationJob
  queue_as :default

  # @raise [RuntimeError] if the (non-nil) druid cannot be found in SDR
  # rubocop:disable Metrics/AbcSize
  def perform(work_version)
    druid = work_version.work.druid # may be nil
    Honeybadger.context({ work_version_id: work_version.id, druid:,
                          work_id: work_version.work.id, depositor_sunet: work_version.work.depositor.sunetid })

    disallow_writes!(work_version)

    cocina_obj = Repository.find(druid) if druid
    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version:, cocina_obj:)

    case request_dro
    when Cocina::Models::RequestDRO
      Rails.logger.info("logging files: work version #{work_version.id}")
      Rails.logger.info("files: #{work_version.staged_local_files.map(&:path)}")
      Rails.logger.info("basepath for files: #{basepath_for(work_version.attached_files.first.file.blob)}")
      Rails.logger.info("filepath_map for files: #{filepath_map_for(work_version)}")
      SdrClient::RedesignedClient.deposit_model(
        accession: true,
        assign_doi: work_version.work.assign_doi?,
        model: request_dro,
        basepath: basepath_for(work_version.attached_files.first.file.blob),
        files: work_version.staged_local_files.map(&:path),
        filepath_map: filepath_map_for(work_version),
        user_versions: user_versions_param(work_version)
      )
    when Cocina::Models::DRO
      Rails.logger.info("not a requestDRO")
      # basepath: basepath_for(work_version.attached_files.first.file.blob),
      # files: work_version.staged_local_files.map(&:path),
      # filepath_map: filepath_map_for(work_version),
      SdrClient::RedesignedClient.update_model(
        model: request_dro,
        version_description: work_version.version_description.presence,
        user_versions: user_versions_param(work_version)
      )
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def filepath_map_for(work_version)
    # attached_file.path contains the cocina filename (e.g. 'dir1/file1.txt')
    work_version.staged_local_files.to_h do |attached_file|
      [attached_file.path, blob_filepath_for(attached_file.file.blob)]
    end
  end

  def basepath_for(blob)
    File.dirname(
      blob_filepath_for(blob)
    )
  end

  def blob_filepath_for(blob)
    ActiveStorage::Blob.service.path_for(blob.key)
  end

  def disallow_writes!(work_version)
    return if work_version.globus_endpoint.blank? ||
              test_mode? ||
              (integration_test_mode? && work_version.globus_endpoint == integration_endpoint)

    # user_id nil because unneeded for permission update operations
    GlobusClient.disallow_writes(path: work_version.globus_endpoint, user_id: nil)
  end

  # simulate globus calls in development if settings indicate we should for testing
  def test_mode?
    Settings.globus.test_mode && Rails.env.development?
  end

  def integration_test_mode?
    Settings.globus.integration_mode
  end

  def integration_endpoint
    Settings.globus.integration_endpoint
  end

  def user_versions_param(work_version)
    return 'none' unless Settings.user_versions_ui_enabled

    work_version.new_user_version? ? 'new' : 'update'
  end
end
