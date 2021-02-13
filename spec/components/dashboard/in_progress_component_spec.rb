# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressComponent, type: :component do
  let(:presenter) do
    instance_double(DashboardPresenter, in_progress: works)
  end
  let(:rendered) { render_inline(described_class.new(presenter: presenter)) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
    create(:work)
    create(:work)
    create(:work)
  end

  context 'when presenter has zero in progress works' do
    let(:works) { Work.none }

    it 'renders the component with a header alone' do
      expect(rendered.to_html).to include('Deposits in progress')
      expect(rendered.to_html).not_to include('Test title')
    end
  end

  context 'when presenter has one or more in progress works' do
    let(:works) { Work.all }

    it 'renders the component with works' do
      expect(rendered.to_html).to include('Deposits in progress')
      works.pluck(:title).each do |title|
        expect(rendered.to_html).to include(title)
      end
    end
  end
end
