# typed: false
# frozen_string_literal: true

module CapybaraActions
  def blur_from(locator)
    field = find_field(locator)
    field.native.send_keys :tab
  end
end

RSpec.configure do |config|
  config.include CapybaraActions, type: :feature
end
