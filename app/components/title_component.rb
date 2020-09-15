class TitleComponent < ViewComponent::Base
  include Motion::Component

  def initialize(form:, update:)
    @form = form
    @update = update
  end

  attr_reader :form
  map_motion :add

  def add(event)
    element = event.target
    @update.call({ title: element.value })
  end
end
