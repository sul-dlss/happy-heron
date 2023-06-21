# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::DepositProgressComponent do
  it "renders the component" do
    expect(render_inline(described_class.new).to_html)
      .to include('turbo-frame id="progress"')
  end
end
