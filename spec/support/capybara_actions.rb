# frozen_string_literal: true

module CapybaraActions
  def blur_from(locator)
    field = find_field(locator)
    field.native.send_keys :tab
  end

  def within_section(title, &block)
    within :xpath, "//section[contains(header/text(),'#{title}')]", &block
  end
end

RSpec.configure do |config|
  config.include CapybaraActions, type: :feature
end
