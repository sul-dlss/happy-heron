# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::ContinueWorkModalComponent, type: :component do
  let(:presenter) do
    instance_double(DashboardPresenter, show_popup?: show_popup, in_progress: [work])
  end
  let(:rendered) { render_inline(described_class.new(presenter: presenter)) }
  let(:work) { build_stubbed(:work) }

  context 'when show_popup is true' do
    let(:show_popup) { true }

    it 'renders the component with a header alone' do
      expect(rendered.to_html).to include 'Would you like to continue working on your draft of'
      expect(rendered.css('.btn-primary').first['href']).to eq "/works/#{work.id}/edit"
      expect(rendered.css('.modal').first['data-controller']).to eq 'popup-modal'
    end
  end
end
