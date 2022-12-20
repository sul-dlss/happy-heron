# frozen_string_literal: true

module ActiveStorage
  class Service
    # This is a little bit different in that most services store the file at the key and the key is opaque,
    # however in this case the key is meaningful in that it stores the path.
    class GlobusService < Service
      SERVICE_NAME = 'globus'

      def download(key, &)
        raise NotImplementedError
      end

      def delete(key)
        # This is called by ActiveSupport when #destroy is called on AttachedFile due to our use
        # of ActiveStorage for file storage.  This can happen during a decommission of a work.
        # We define this as a noop, because we explictly do not want the related preservation
        # file to be destroyed in this case and we do not want the NotImplementedError exception
        # to be raised to HB either: https://app.honeybadger.io/projects/77112/faults/88770594
      end

      def self.encode_key(druid, version, path)
        [druid, version, path].join('/')
      end

      # @return [Boolean] true if this blob is for the GlobusService
      def self.accessible?(blob)
        blob.service_name == SERVICE_NAME
      end
    end
  end
end
