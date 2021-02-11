# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::DepositProgressComponent, type: :component do
  let(:component) { described_class.new(work_version: work_version) }
  let(:work) { build_stubbed(:work, collection: build(:collection, :with_contact_emails, id: 7)) }
  let(:work_version) { build_stubbed(:work_version, work: work) }
  let(:rendered) { render_inline(component) }

  context 'when work is new' do
    let(:work) { build(:work) }

    it 'only license and release are marked as active' do
      expect(rendered.css('li.active').size).to eq 2
    end
  end

  context 'when work has a title' do
    let(:work_version) { build_stubbed(:work_version, :with_contact_emails, work: work) }

    it 'marks some steps as active' do
      expect(rendered.css('li.active').size).to eq 3
    end
  end

  context 'when work has everything' do
    let(:work_version) { build_stubbed(:valid_work_version, attached_files: [build_stubbed(:attached_file)]) }

    it 'marks all steps as active' do
      expect(rendered.css('li.active').size).to eq 6
    end
  end
end
