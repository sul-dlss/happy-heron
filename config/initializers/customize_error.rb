# typed: false
# frozen_string_literal: true

# By default rails wraps <label> tags with a div, which screws up Boostrap layouts
# See https://guides.rubyonrails.org/configuring.html#configuring-action-view
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  class_attr_index = html_tag.index 'class="'

  if class_attr_index
    html_tag.insert class_attr_index + 7, 'is-invalid '
  else
    html_tag.insert html_tag.index('>'), ' class="is-invalid"'
  end
end
