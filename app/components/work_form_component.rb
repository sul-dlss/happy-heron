class WorkFormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :work

  def initialize(work:)
    @work = work
  end

  def update_model(opts)
    @work.attributes = opts
    true
  end
end
