class WorkFormComponent < ViewComponent::Base
  include Motion::Component

  attr_reader :data

  def initialize
    @data = {}.with_indifferent_access
  end

  def update_model(opts)
    @data.merge! opts
    true
  end
end
