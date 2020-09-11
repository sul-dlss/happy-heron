class TitleComponent < ViewComponent::Base
  include Motion::Component

  def initialize(update:)
    @update = update
  end

  map_motion :add

  attr_reader :text

  def add(event)
    element = event.current_target
    @text = element.value
    @update.call({title: element.value})
  end
end
