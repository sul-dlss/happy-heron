# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work: work)) }
  let(:work) { build_stubbed(:work) }

  it 'renders the component' do
    expect(rendered.css("turbo-frame#delete_work_#{work.id}").first['src']).to be_present
    expect(rendered.to_html).to include work.title
  end
end
