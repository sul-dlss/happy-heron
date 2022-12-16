# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::FilesComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version:)) }
  let(:work_version) { create(:work_version) }

  context 'with an attached file' do
    before do
      create(:attached_file, :with_file, work_version:)
    end

    it 'renders the turbo frame and spinner' do
      expect(rendered.css('turbo-frame')[0]['src']).to eq "/works/#{work_version.work.id}/files_list"
      expect(rendered.to_html).to include 'fa-solid fa-spinner fa-pulse'
    end
  end
end
