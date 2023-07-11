# frozen_string_literal: true

module CapybaraActions
  def blur_from(locator)
    field = find_field(locator)
    field.native.send_keys :tab
  end

  def within_section(title, &)
    within(:xpath, "//section[contains(header/text(),'#{title}')]", &)
  end

  # An alias so our tests are less coupled to the aXe implementation
  def be_accessible(...)
    be_axe_clean(...).according_to(
      :wcag21a,
      :wcag21aa,
      :"best-practice",
      :experimental
    )
  end
end

RSpec.configure do |config|
  config.include CapybaraActions, type: :feature
end
