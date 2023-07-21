# frozen_string_literal: true

# Support for nested forms.
class NestedFormComponent < ApplicationComponent
  # Optional slot. If provided, the button must have add as its action for the controller.
  # See H2FormBuilder#add_another_button
  renders_one :add_another_button

  def initialize(controller:, form:, field:, clazz:, row:, ordered: false)
    @controller = controller
    @form = form
    @field = field
    @clazz = clazz
    @row = row
    @ordered = ordered
  end

  attr_reader :controller, :form, :field, :clazz, :row, :ordered

  def nested_forms
    # Form object must have a method that returns nested forms for this field.
    form.object.send("#{field}_forms".to_sym)
  end

  def other_row_params
    ordered ? {ordered:} : {}
  end
end
