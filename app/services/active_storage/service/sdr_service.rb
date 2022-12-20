# frozen_string_literal: true

module ActiveStorage
  class Service
    # This is a little bit different in that most services store the file at the key and the key is opaque,
    # however in this case the key is meaningful in that it stores the druid, version and filepath.
    class SdrService < Service
      SERVICE_NAME = 'preservation'

      def download(key, &block)
        raise NotImplementedError unless block

        instrument(:streaming_download, key:) do
          stream(key, &block)
        end
      end

      def delete(key)
        # This is called by ActiveSupport when #destroy is called on AttachedFile due to our use
        # of ActiveStorage for file storage.  This can happen during a decommission of a work.
        # We define this as a noop, because we explictly do not want the related preservation
        # file to be destroyed in this case and we do not want the NotImplementedError exception
        # to be raised to HB either: https://app.honeybadger.io/projects/77112/faults/88770594
      end

      def self.encode_key(druid, version, filepath)
        [druid, version, filepath].join('/')
      end

      # @return [Boolean] true if this blob is for the SdrService
      def self.accessible?(blob)
        blob.service_name == SERVICE_NAME
      end

      private

      def stream(key)
        address = split_key(key)
        Preservation::Client.objects.content(
          **address,
          on_data: proc { |data, _count| yield data }
        )
      end

      def split_key(key)
        druid, version, filepath = key.split('/', 3)
        { druid:, version:, filepath: }
      end
    end
  end
end
