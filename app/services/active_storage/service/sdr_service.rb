# frozen_string_literal: true

module ActiveStorage
  class Service
    # This is a little bit different in that most services store the file at the key and the key is opaque,
    # hoewever in this case the key is meaningful in that it stores the druid, version and filepath.
    class SdrService < Service
      def download(key, &block)
        raise NotImplementedError unless block

        instrument :streaming_download, key: key do
          stream(key, &block)
        end
      end

      def self.encode_key(druid, version, filepath)
        [druid, version, filepath].join('/')
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
