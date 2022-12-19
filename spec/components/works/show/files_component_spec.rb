# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::FilesComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { create(:work_version) }

  context 'with an attached file' do
    before do
      create(:attached_file, :with_file, work_version:)
    end

    it 'shows a download link and the hide status' do
      expect(rendered.css('a').last['href']).to start_with '/rails/active_storage/blobs/redirect/'
      expect(rendered.css('td').last.to_html).to include 'No'
    end
  end

  context 'with multiple attached files' do
    let(:attached_file) { create(:attached_file, :with_file, path: 'sul.svg') }
    let(:attached_file2) { create(:attached_file, :with_file, path: 'favicon.ico') }
    let(:work_version) { create(:work_version, attached_files: [attached_file, attached_file2]) }

    it 'shows them in alpha order' do
      expect(rendered.css('tr')[1].to_html).to include 'favicon.ico'
      expect(rendered.css('tr')[2].to_html).to include 'sul.svg'
    end
  end
end
