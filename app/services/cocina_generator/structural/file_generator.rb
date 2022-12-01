# frozen_string_literal: true

module CocinaGenerator
  module Structural
    # This generates a Cocina File for a work
    class FileGenerator
      def self.generate(work_version:, attached_file:, external_identifier: nil)
        new(work_version:, attached_file:, external_identifier:).generate
      end

      def initialize(work_version:, attached_file:, external_identifier:)
        @work_version = work_version
        @attached_file = attached_file
        @external_identifier = external_identifier # may be nil
      end

      attr_reader :work_version, :attached_file, :external_identifier

      def generate
        return nil unless blob

        if work_version.work.druid
          Cocina::Models::File.new(file_attributes)
        else
          Cocina::Models::RequestFile.new(request_file_attributes)
        end
      end

      def request_file_attributes
        {
          type: Cocina::Models::ObjectType.file,
          version: work_version.version,
          label: attached_file.label,
          filename:,
          access:,
          administrative:,
          hasMimeType: blob.content_type,
          hasMessageDigests: message_digests,
          size: blob.byte_size
        }
      end

      def file_attributes
        request_file_attributes.merge(externalIdentifier: create_external_identifier)
      end

      def filename
        blob.filename.to_s # File.basename(filename(blob.key))
      end

      def create_external_identifier
        external_identifier || ("#{work_version.work.druid}/#{filename}" if work_version.work.druid)
      end

      def administrative
        {
          publish: !hidden_file?,
          sdrPreserve: true,
          shelve: !hidden_file?
        }
      end

      def message_digests
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
