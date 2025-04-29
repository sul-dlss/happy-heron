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
          Cocina::Models::RequestFile.new(file_attributes)
        end
      end

      def file_attributes
        {
          type: Cocina::Models::ObjectType.file,
          version: work_version.version,
          label: attached_file.label,
          filename:,
          access:,
          administrative:,
          hasMimeType: mime_type,
          hasMessageDigests: message_digests,
          size:,
          externalIdentifier: external_identifier
        }.compact
      end

      def filename
        cocina_file&.filename || attached_file.path
      end

      def external_identifier
        # see https://github.com/sul-dlss/dor-services-app/blob/main/app/services/cocina/id_generator.rb
        return cocina_file.externalIdentifier if cocina_file

        return "globus://#{work_version.globus_endpoint}/#{attached_file.path}" if attached_file.in_globus?

        # Cocina::Models::File need an external identifier
        return blob.signed_id if work_version.work.druid

        nil
      end

      def administrative
        {
          publish: !hidden_file?,
          sdrPreserve: true,
          shelve: !hidden_file?
        }
      end

      def message_digests
        return [] if attached_file.in_globus?
        return cocina_file.hasMessageDigests if cocina_file

        [
          { type: 'md5', digest: attached_file.md5 },
          { type: 'sha1', digest: Digest::SHA1.file(file_path(blob.key)).hexdigest }
        ]
      end

      def size
        return if attached_file.in_globus?
        return cocina_file.size if cocina_file

        blob.byte_size
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

      def mime_type
        return if attached_file.in_globus?
        return cocina_file.hasMimeType if cocina_file

        blob.content_type
      end
    end
  end
end
