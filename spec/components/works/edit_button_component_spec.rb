# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EditButtonComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(work_version: work_version)) }

  context 'when the work is a draft' do
    let(:work_version) { build_stubbed(:work_version, :first_draft) }

    it 'renders the link' do
      expect(rendered.css('a').text).to eq 'Edit or Deposit'
    end
  end

  context 'when the work is deposited' do
    let(:work_version) { build_stubbed(:work_version, :deposited) }

    it 'does not render the link' do
      expect(rendered.css('a')).to be_empty
    end
  end

  context 'when the work is being reviewed' do
    let(:work_version) { build_stubbed(:work_version, :pending_approval) }

    it 'does not render the link' do
      expect(rendered.css('a')).to be_empty
    end
  end
end
