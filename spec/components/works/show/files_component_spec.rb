# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::FilesComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version: work_version)) }
  let(:work_version) { create(:work_version) }

  context 'with an attached file' do
    before do
      create(:attached_file, :with_file, work_version: work_version)
    end

    it 'shows a download link and the hide status' do
      expect(rendered.css('a').last['href']).to start_with '/rails/active_storage/blobs/redirect/'
      expect(rendered.css('td').last.to_html).to include 'No'
    end
  end
end
