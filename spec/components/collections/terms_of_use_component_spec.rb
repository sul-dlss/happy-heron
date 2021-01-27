# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::TermsOfUseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(collection: collection)).to_html }

  let(:collection) { build_stubbed(:collection, required_license: required_license, default_license: default_license) }

  context 'with a collection that has a required license' do
    let(:default_license) { nil }
    let(:required_license) { 'MIT' }

    it { is_expected.to include(required_license) }
    it { is_expected.to include('Required license') }
  end

  context 'with a collection that has a default license' do
    let(:default_license) { 'Apache-2.0' }
    let(:required_license) { nil }

    it { is_expected.to include(default_license) }
    it { is_expected.to include('Default license (depositor selects)') }
  end

  context 'with a collection that has no licenses' do
    let(:default_license) { nil }
    let(:required_license) { nil }

    it { is_expected.not_to include('Required license') }
    it { is_expected.not_to include('Default license (depositor selects)') }
  end
end
