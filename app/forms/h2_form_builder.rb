class H2FormBuilder < ActionView::Helpers::FormBuilder
  def add_another_button(controller, content_or_options = nil, options = nil, &block)
    button_with_action("#{controller}#add", content_or_options, options, &block)
  end

  def remove_button(controller, content_or_options = nil, options = nil, &block)
    button_with_action("#{controller}#remove", content_or_options, options, &block)
  end

  def move_up_button(controller, content_or_options = nil, options = nil, &block)
    button_with_action("#{controller}#moveUp", content_or_options, options, {"#{controller}_target": "upButton"}, &block)
  end

  def move_down_button(controller, content_or_options = nil, options = nil, &block)
    button_with_action("#{controller}#moveDown", content_or_options, options, "#{controller}_target": "downButton", &block)
  end

  private

  def button_with_action(action, content_or_options = nil, options = nil, addl_data = nil, &block)
    if content_or_options.is_a? Hash
      options = content_or_options
    else
      options ||= {}
    end

    # Handle merging data-action.
    options = {type: "button", data: {action: action}}.deep_stringify_keys.deep_merge({"data" => addl_data || {}}).deep_merge(options.deep_stringify_keys) do |key, this_val, other_val|
      if key == "action"
        "#{this_val} #{other_val}"
      else
        this_val
      end
    end

    if block
      @template.content_tag :button, options, nil, false, &block
    else
      @template.content_tag :button, content_or_options || "Button", options
    end
  end
end
