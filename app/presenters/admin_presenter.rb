# frozen_string_literal: true

# The page model for the admin page
class AdminPresenter
  def initialize
    @work_stats = StatBuilder.build_stats
  end
  attr_accessor :work_stats
end
