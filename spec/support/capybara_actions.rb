# frozen_string_literal: true

module CapybaraActions
  def blur_from(locator)
    field = find_field(locator)
    field.native.send_keys :tab
  end

  def within_section(title, &)
    within(:xpath, "//section[contains(header/text(),'#{title}')]", &)
  end

  # NOTE: this is here to ensure all turbo frames are loaded before auditing a11y
  def visit_and_wait_for_complete_frames(path)
    visit path

    # I tried 3-4 "smarter" ways to get Capybara to wait for turbo-frames to load and all of them were flaky.
    sleep 1
  end

  # An alias so our tests are less coupled to the aXe implementation
  def be_accessible(...)
    be_axe_clean(...).according_to(
      :"best-practice",
      :wcag21a,
      :wcag21aa
    )
  end
end

RSpec.configure do |config|
  config.include CapybaraActions, type: :feature
end
