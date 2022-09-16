# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::EmbargoComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:collection) { build(:collection, :depositor_selects_access, release_option: 'immediate') }
  let(:work) { build(:work, collection:) }
  let(:work_version) { build(:work_version, work:) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(described_class.new(form:)) }

  before do
    work.head = work_version
    work_form.prepopulate!
  end

  it 'renders the component' do
    expect(rendered.to_html)
      .to include('Settings for release date and download access')
    expect(rendered.to_html)
      .to include('DOI assignment')
  end

  context 'when user can choose availability' do
    let(:collection) { build(:collection, release_option: 'depositor-selects') }

    it 'renders the component' do
      expect(rendered.to_html)
        .to include('Select when the files in your deposit will be downloadable from the PURL page.')
    end
  end

  context 'when the collection is configured for immediate deposit' do
    it 'renders the component' do
      expect(rendered.to_html).to include 'Immediately upon deposit.'
    end
  end

  context 'when the collection allows depositor to select release timing' do
    let(:collection) do
      build(:collection, :depositor_selects_access, release_option: 'depositor-selects', review_enabled:)
    end

    context 'when collection does not require review' do
      let(:review_enabled) { false }

      it 'renders the component' do
        expect(rendered.to_html).to include 'you click "Deposit" at the bottom of this page'
      end
    end

    context 'when collection requires review' do
      let(:review_enabled) { true }

      it 'renders the component' do
        expect(rendered.to_html).to include 'your deposit is approved'
      end
    end
  end

  context 'when the collection is configured for a specific date' do
    let(:collection) { build(:collection, release_option: 'delay', release_duration: '1 year') }
    let(:release_date) { (Time.zone.today + 1.year).to_fs(:long) }

    it 'renders the component' do
      expect(rendered.to_html).to include "Starting on #{release_date}"
    end
  end

  context 'when the collection has been deposited and release is immediate' do
    let(:work_version) { build(:work_version, work:, state: 'deposited') }

    it 'renders the component' do
      expect(rendered.to_html).to include 'This item was released immediately upon deposit.'
    end
  end

  context 'when the collection has been deposited and embargo has elapsed' do
    let(:work_version) { build(:work_version, work:, state: 'deposited', embargo_date: Time.zone.today - 1.month) }

    it 'renders the component' do
      expect(rendered.to_html).to include 'This item has been released from embargo.'
    end
  end

  context 'when the collection has been deposited and embargo date is today' do
    let(:work_version) { build(:work_version, work:, state: 'deposited', embargo_date: Time.zone.today) }

    it 'renders the component' do
      expect(rendered.to_html).to include 'This item has been released from embargo.'
    end
  end

  context 'when the collection has been deposited and embargo has not elapsed' do
    let(:collection) { build(:collection, :depositor_selects_access, release_option: 'depositor-selects') }
    let(:work_version) { build(:work_version, work:, state: 'deposited', embargo_date: Time.zone.today + 1.month) }

    it 'renders the component' do
      expect(rendered.to_html)
        .to include('Select when the files in your deposit will be downloadable from the PURL page.')
    end
  end
end
