# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionForm do
  subject(:form) { described_class.new(collection) }

  let(:collection) { build(:collection, required_license: required_license, default_license: default_license) }
  let(:default_license) { nil }
  let(:required_license) { nil }

  # NOTE: license validation is not tested in this spec; it is tested in the
  #       CollectionLicenseValidator spec.
  describe 'license_option prepopulator' do
    before do
      form.prepopulate!
    end

    context 'when default_license is set' do
      let(:default_license) { 'CC0-1.0' }

      it 'sets license_option to "depositor-selects"' do
        expect(form.license_option).to eq('depositor-selects')
      end
    end

    context 'when required_license is set' do
      let(:required_license) { 'Apache-2.0' }

      it 'sets license_option to "required"' do
        expect(form.license_option).to eq('required')
      end
    end
  end

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
