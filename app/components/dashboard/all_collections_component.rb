# typed: false
# frozen_string_literal: true

module Dashboard
  # Renders a list of all collections
  class AllCollectionsComponent < ApplicationComponent
    sig { params(stats: T.nilable(T::Hash[Collection, Hash])).void }
    def initialize(stats:)
      @stats = stats
    end

    attr_reader :stats

    def render?
      stats.present?
    end
  end
end
