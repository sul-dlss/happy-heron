# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BreadcrumbNavComponent, type: :component do
  let(:nav) { described_class.new(breadcrumbs: breadcrumbs) }
  let(:rendered) { render_inline(nav) }

  context 'when no breadcrumbs' do
    let(:breadcrumbs) { [] }

    it 'renders nav' do
      expect(rendered.css('div').to_html).to include 'Dashboard'
    end

    it 'sets title' do
      expect(nav.title_from_breadcrumbs).to eq('SDR | Dashboard')
    end
  end

  context 'when breadcrumbs' do
    let(:breadcrumbs) do
      [{ title: 'Collection', link: '/path_to_collection' },
       { title: 'Work', link: '/path_to_work' },
       { title: 'Edit', omit_title: true }]
    end

    it 'renders nav' do
      expect(rendered.css('div').to_html).to include('Dashboard')
      expect(rendered.css('div').to_html).to include('Collection')
      expect(rendered.css('div').to_html).to include('Work')
      expect(rendered.css('div').to_html).to include('Edit')
    end

    it 'sets title' do
      expect(nav.title_from_breadcrumbs).to eq('SDR | Collection | Work')
    end
  end
end
