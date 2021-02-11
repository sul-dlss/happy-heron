# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::InProgressComponent, type: :component do
  let(:presenter) do
    DashboardPresenter.new(
      in_progress: work_versions,
      approvals: Work.none,
      collections: Collection.none,
      collection_managers_in_progress: Collection.none
    )
  end
  let(:rendered) { render_inline(described_class.new(presenter: presenter)) }

  before do
    allow(controller).to receive(:allowed_to?).and_return(true)
  end

  context 'when presenter has zero in progress works' do
    let(:work_versions) { WorkVersion.none }

    it 'renders the component with a header alone' do
      expect(rendered.to_html).to include('Deposits in progress')
      expect(rendered.to_html).not_to include('Test title')
    end
  end

  context 'when presenter has one or more in progress works' do
    let(:work_versions) { WorkVersion.all }

    before do
      create(:work_version)
      create(:work_version)
      create(:work_version)
    end

    it 'renders the component with works' do
      expect(rendered.to_html).to include('Deposits in progress')
      work_versions.pluck(:title).each do |title|
        expect(rendered.to_html).to include(title)
      end
    end
  end
end
