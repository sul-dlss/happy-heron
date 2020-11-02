# typed: true
# frozen_string_literal: true

module Works
  # Draws a popup for selecting work type and subtype
  class CreateModalComponent < ApplicationComponent
    def types
      WorkType.all
    end
  end
end
