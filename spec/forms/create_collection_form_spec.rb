# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateCollectionForm do
  subject(:form) { described_class.new(collection:, collection_version:) }

  let(:collection) { build(:collection, required_license:, default_license:) }
  let(:collection_version) { build(:collection_version) }
  let(:default_license) { nil }
  let(:required_license) { nil }

  describe '#deserialize!' do
    subject(:deserialized) { form.deserialize!(params) }

    let(:default_license) { 'MIT' }
    let(:required_license) { 'Apache-2.0' }
    let(:params) do
      {
        'default_license' => default_license,
        'required_license' => required_license,
        'license_option' => license_option
      }
    end

    context 'when license_option is "required"' do
      let(:license_option) { 'required' }

      it 'sets default_license to nil' do
        expect(deserialized['default_license']).to be_nil
        expect(deserialized['required_license']).to eq('Apache-2.0')
      end
    end

    context 'when license_option is "depositor-selects"' do
      let(:license_option) { 'depositor-selects' }

      it 'sets required_license to nil' do
        expect(deserialized['required_license']).to be_nil
        expect(deserialized['default_license']).to eq('MIT')
      end
    end
  end
end
