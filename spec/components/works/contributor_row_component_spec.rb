# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContributorRowComponent do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, author, controller.view_context, {}) }
  let(:component) { described_class.new(form:, is_author:) }
  let(:rendered) { render_inline(component) }
  let(:author) { build_stubbed(:person_author, orcid:) }
  let(:is_author) { true }
  let(:orcid) { nil }

  it 'renders the hidden fields and controls' do
    expect(rendered.css('input[name*="weight"]')).to be_present
    expect(rendered.css('button[aria-label="Move up"]')).to be_present
    expect(rendered.css('button[aria-label="Move down"]')).to be_present
    expect(rendered.css('input[name*="_destroy"]')).to be_present
    expect(rendered.css('button[aria-label="Remove"]')).to be_present
  end

  context 'when an author' do
    it 'has required inputs' do
      expect(rendered.css('input[required = "required"]')).to be_present
      expect(rendered.to_html).to include(' *')
    end

    it 'updates citation' do
      expect(rendered.to_html).to include('auto-citation#updateDisplay')
    end
  end

  context 'when a contributor' do
    let(:is_author) { false }

    it 'does not have required inputs' do
      expect(rendered.css('input[required = "required"]')).not_to be_present
      expect(rendered.to_html).not_to include(' *')
    end

    it 'does not update citation' do
      expect(rendered.to_html).not_to include('auto-citation#updateDisplay')
    end
  end

  context 'when author with ORCID' do
    let(:orcid) { 'https://orcid.org/0000-0002-1825-0097' }

    it 'shows ORCID' do
      expect(rendered.css('input[aria-label="Enter author by name"]:not([checked])')).to be_present
      expect(rendered.css('input[aria-label="Enter author by ORCID iD"][checked="checked"]')).to be_present
      expect(rendered.to_html).to include('https://orcid.org/0000-0002-1825-0097')
    end
  end

  context 'when author without ORCID' do
    it 'shows person name' do
      expect(rendered.css('input[aria-label="Enter author by name"][checked="checked"]')).to be_present
      expect(rendered.css('input[aria-label="Enter author by ORCID iD"]:not([checked])')).to be_present
    end
  end
end
