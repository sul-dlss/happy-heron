# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::TermsOfUseComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(collection: collection)).to_html }

  let(:collection_version) { build_stubbed(:collection_version) }

  context 'with a collection that has a required license' do
    let(:collection) do
      build_stubbed(:collection, :with_required_license, required_license: required_license,
                                                         head: collection_version)
    end
    let(:required_license) { 'MIT' }

    it { is_expected.to include(required_license) }
    it { is_expected.to include('Required license') }
  end

  context 'with a collection that has a default license' do
    let(:collection) do
      build_stubbed(:collection, default_license: default_license, head: collection_version)
    end
    let(:default_license) { 'Apache-2.0' }

    it { is_expected.to include(default_license) }
    it { is_expected.to include('Default license (depositor selects)') }
  end
end
