# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::LinkToShowComponent, type: :component do
  let(:render) { render_inline(described_class.new(work_version: work_version)) }
  let(:work_version) { build_stubbed(:work_version, title: title) }
  let(:title) do
    "Marfa gochujang 90's, normcore lomo chartreuse ethical man bun fashion axe " \
    'palo santo asymmetrical post-ironic. Kitsch sriracha affogato wayfarers woke neutra.'
  end

  it 'truncates the link' do
    expect(render.css('a').first['title']).to eq title
    expect(render.css('a').text).to eq "Marfa gochujang 90's, normcore lomo " \
      'chartreuse ethical man bun fashion axe palo santo asymmetrical post-ironic. ' \
      'Kitsch sriracha affogato wayfarers...'
  end
end
