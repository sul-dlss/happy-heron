# typed: true
# frozen_string_literal: true

module Works
  module Show
    # Displays an ORCID id
    class OrcidComponent < ApplicationComponent
      def initialize(orcid:)
        @orcid = orcid
      end

      attr_reader :orcid
    end
  end
end
