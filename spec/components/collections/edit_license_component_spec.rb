# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::EditLicenseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(form: form)) }

  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version) }

  let(:collection_form) { CreateCollectionForm.new(collection: collection, collection_version: collection_version) }
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, collection_form, controller.view_context, {}) }

  context 'with no license selected' do
    it 'renders the prompt for the required license' do
      expect(rendered.to_html).to include('Select...')
    end
  end

  context 'with a required license selected' do
    let(:collection) { build(:collection, required_license: 'MIT') }

    it 'selects the MIT license' do
      expect(rendered.to_html).to include('<option selected value="MIT">MIT License</option>')
    end
  end

  context 'with a default license selected' do
    let(:collection) { build(:collection, default_license: 'CC0-1.0') }

    it 'selects the CC0 license' do
      expect(rendered.to_html).to include('<option selected value="CC0-1.0">CC0-1.0</option>')
    end
  end

  context 'with errors' do
    let(:collection) { build(:collection, required_license: nil) }

    before do
      collection_form.errors.add(:license, 'Either a required license or a default license must be present')
    end

    it 'renders the message and adds invalid styles' do
      expect(rendered.css('.is-invalid ~ .invalid-feedback').text).to eq(
        'Either a required license or a default license must be present'
      )
      expect(rendered.css('#required_license.is-invalid')).to be_present
      expect(rendered.css('#default_license.is-invalid')).to be_present
    end
  end
end
