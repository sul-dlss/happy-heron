class TitleComponent < ViewComponent::Base
  def initialize(form:, update:)
    @form = form
    @update = update
  end

  attr_reader :form
end
