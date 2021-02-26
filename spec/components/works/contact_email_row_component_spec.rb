# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::ContactEmailRowComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(form: form_builder, key: 'collection.contact_email')) }

  let(:collection) { build(:collection) }
  let(:collection_version) { build(:collection_version) }

  let(:parent_form) { CreateCollectionForm.new(collection: collection, collection_version: collection_version) }
  let(:email_form) do
    parent_form.prepopulate!
    parent_form.contact_emails.first
  end
  let(:form_builder) do
    ActionView::Helpers::FormBuilder.new('collection', email_form, controller.view_context, {})
  end

  context 'when valid' do
    it 'is not invalid' do
      expect(rendered.css('.is-invalid')).not_to be_present
    end
  end

  context 'with errors' do
    before do
      email_form.errors.add(:email, 'is invalid')
    end

    it 'adds invalid styles' do
      expect(rendered.css('.is-invalid ~ .invalid-feedback').text).to eq(
        'You must provide a valid email address'
      )
      expect(rendered.css('#collection_email.is-invalid')).to be_present
    end
  end
end
