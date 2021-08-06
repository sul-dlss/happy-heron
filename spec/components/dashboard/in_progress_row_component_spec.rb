# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressRowComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version: work_version)) }
  let(:work_version) { build_stubbed(:work_version, work: work) }
  let(:work) { build_stubbed(:work, collection: collection) }
  let(:collection_version) { build_stubbed(:collection_version) }
  let(:collection) { build_stubbed(:collection, head: collection_version) }

  it 'renders the component' do
    expect(rendered.css("turbo-frame#delete_work_#{work_version.work.id}").first['src']).to be_present
    expect(rendered.to_html).to include work_version.title
  end
end
