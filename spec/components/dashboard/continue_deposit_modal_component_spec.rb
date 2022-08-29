# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::ContinueDepositModalComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(presenter: presenter)) }

  context 'when show_popup is true' do
    let(:show_popup) { true }

    context 'when only a work is in progress' do
      let(:work_version) { build_stubbed(:work_version_with_work) }
      let(:presenter) do
        instance_double(DashboardPresenter, show_popup?: show_popup, in_progress: [work_version],
                                            collection_managers_in_progress: [])
      end

      it 'renders the component to resume work' do
        expect(rendered.to_html).to include 'Would you like to continue working on your draft work'
        expect(rendered.css('.btn-primary').first['href']).to eq "/works/#{work_version.work.id}/edit"
        expect(rendered.css('.modal').first['data-controller']).to eq 'popup-modal'
      end
    end

    context 'when both work and collection in progress' do
      let(:work_version) { build_stubbed(:work_version_with_work) }
      let(:collection_version) { build_stubbed(:collection_version) }
      let(:presenter) do
        instance_double(DashboardPresenter, show_popup?: show_popup, in_progress: [work_version],
                                            collection_managers_in_progress: [collection_version])
      end

      it 'renders the component to resume collection' do
        expect(rendered.to_html).to include 'Would you like to continue working on your draft collection'
        expect(rendered.css('.btn-primary').first['href']).to eq "/collections/#{collection_version.collection.id}/edit"
        expect(rendered.css('.modal').first['data-controller']).to eq 'popup-modal'
      end
    end

    context 'when only a collection is in progress' do
      let(:collection_version) { build_stubbed(:collection_version) }
      let(:presenter) do
        instance_double(DashboardPresenter, show_popup?: show_popup, in_progress: [],
                                            collection_managers_in_progress: [collection_version])
      end

      it 'renders the component to resume collection' do
        expect(rendered.to_html).to include 'Would you like to continue working on your draft collection'
        expect(rendered.css('.btn-primary').first['href']).to eq "/collections/#{collection_version.collection.id}/edit"
        expect(rendered.css('.modal').first['data-controller']).to eq 'popup-modal'
      end
    end
  end

  context 'when show_popup is false' do
    let(:show_popup) { false }
    let(:presenter) do
      instance_double(DashboardPresenter, show_popup?: show_popup, in_progress: [], collection_managers_in_progress: [])
    end

    it 'does not render the component' do
      expect(rendered.to_html).to eq ''
    end
  end
end
