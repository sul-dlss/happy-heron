# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedLinkComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, model_form, controller.view_context, {}) }
  let(:related_links) do
    [
      build_stubbed(:related_link, link_title: 'First Link'),
      build_stubbed(:related_link, link_title: 'Second Link')
    ]
  end
  let(:rendered) { render_inline(described_class.new(form: form)) }

  context 'with a work' do
    let(:work) { work_version.work }
    let(:work_version) { build_stubbed(:work_version, related_links: related_links) }
    let(:model_form) { WorkForm.new(work_version: work_version, work: work) }

    it 'renders a delete button for all links but the first' do
      expect(rendered.css('button[@aria-label="Remove Second Link"]')).to be_present
      expect(rendered.css('button[@aria-label="Remove First Link"]')).not_to be_present
    end
  end

  context 'with a collection' do
    let(:model_form) { CollectionForm.new(model) }
    let(:model) { build_stubbed(:collection, related_links: related_links) }

    it 'renders a delete button for all links but the first' do
      expect(rendered.css('button[@aria-label="Remove Second Link"]')).to be_present
      expect(rendered.css('button[@aria-label="Remove First Link"]')).not_to be_present
    end
  end
end
