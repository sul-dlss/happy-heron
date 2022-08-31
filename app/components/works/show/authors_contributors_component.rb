# frozen_string_literal: true

module Works
  module Show
    # Displays the author or contributor table on the show page
    class AuthorsContributorsComponent < ApplicationComponent
      attr_reader :work, :participants, :participant_type

      def initialize(work:, participants:, participant_type:)
        @work = work
        @participants = participants
        @participant_type = participant_type
      end
    end
  end
end
