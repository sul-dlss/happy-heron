# frozen_string_literal: true

module CocinaGenerator
  module Structural
    # This generates a Cocina File for a work
    class FileGenerator
      def self.generate(work_version:, attached_file:, resource_id: nil, cocina_file: nil)
        new(work_version:, attached_file:, resource_id:, cocina_file:).generate
      end

      def initialize(work_version:, attached_file:, resource_id: nil, cocina_file: nil)
        @work_version = work_version
        @attached_file = attached_file
        @resource_id = resource_id
        @cocina_file = cocina_file

        raise 'Either resource_id or cocina_file should be provided.' if resource_id.nil? && cocina_file.nil?
      end

      attr_reader :work_version, :attached_file, :resource_id, :cocina_file

      def generate
        return nil unless blob

        if work_version.work.druid
          Cocina::Models::File.new(file_attributes)
        else
          Cocina::Models::RequestFile.new(request_file_attributes)
        end
      end

      # rubocop:disable Metrics/AbcSize
      def request_file_attributes
        {
          type: Cocina::Models::ObjectType.file,
          version: work_version.version,
          label: attached_file.label,
          filename:,
          access:,
          administrative:,
          hasMimeType: cocina_file&.hasMimeType || blob.content_type,
          hasMessageDigests: message_digests,
          size: cocina_file&.size || blob.byte_size
        }
      end
      # rubocop:enable Metrics/AbcSize

      def file_attributes
        request_file_attributes.merge(externalIdentifier: external_identifier)
      end

      def filename
        cocina_file&.filename || attached_file.path
      end

      def external_identifier
        # see https://github.com/sul-dlss/dor-services-app/blob/main/app/services/cocina/id_generator.rb
        cocina_file&.externalIdentifier || blob.signed_id
      end

      def administrative
        {
          publish: !hidden_file?,
          sdrPreserve: true,
          shelve: !hidden_file?
        }
      end

      def message_digests
        cocina_file&.hasMessageDigests ||
          [
            { type: 'md5', digest: base64_to_hexdigest(blob.checksum) },
            { type: 'sha1', digest: Digest::SHA1.file(file_path(blob.key)).hexdigest }
          ]
      end

      delegate :blob, to: :attached_file

      def hidden_file?
        attached_file.hide?
      end

      def embargoed?
        work_version.embargo_date
      end

      def access
        if embargoed?
          { view: 'dark', download: 'none' }
        else
          { view: work_version.access, download: work_version.access }
        end
      end

      def file_path(key)
        ActiveStorage::Blob.service.path_for(key)
      end

      def base64_to_hexdigest(base64)
        Base64.decode64(base64).unpack1('H*')
      end
    end
  end
end
