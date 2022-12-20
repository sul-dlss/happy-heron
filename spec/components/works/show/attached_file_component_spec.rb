# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::AttachedFileComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(attached_file:, work_version:)) }
  let(:work_version) { create(:work_version, attached_files: [attached_file]) }
  let(:attached_file) { build(:attached_file, :with_file) }

  context 'with an attached file' do
    it 'shows a download link and the hide status' do
      expect(rendered.css('a').last['href']).to start_with '/rails/active_storage/blobs/redirect/'
      expect(rendered.css('td').last.to_html).to include 'No'
    end
  end
end
