# frozen_string_literal: true

# An abstract base class for all the populators
class ApplicationPopulator
  def initialize(field, klass)
    @field = field
    @klass = klass
  end

  attr_reader :field
  attr_reader :klass

  def existing_record(form:, id:)
    value(form).find_by(id:) if id.present?
  end

  def value(form)
    form.public_send(field)
  end

  def skip!
    Representable::Pipeline::Stop
  end
end
