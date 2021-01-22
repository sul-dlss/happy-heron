# frozen_string_literal: true

@form.errors.each do |error|
  # Transform the property name in the model to the value used by the javascript:
  json.set! error.attribute == :reviewer_sunets ? 'reviewerSunets' : error.attribute, [error.message]
end
