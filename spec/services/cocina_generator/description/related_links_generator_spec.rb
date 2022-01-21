# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CocinaGenerator::Description::RelatedLinksGenerator do
  subject(:model) { described_class.generate(object: work_version).map(&:to_h) }

  context 'with external URIs' do
    let(:work_version) do
      build(:work_version, related_links: [build(:related_link), build(:related_link)])
    end

    it 'creates related links' do
      expect(model).to eq([
                            Cocina::Models::RelatedResource.new({
                                                                  title: [
                                                                    { value: 'My Awesome Research' }
                                                                  ],
                                                                  access: { url: [
                                                                    { value: 'http://my.awesome.research.io' }
                                                                  ] }
                                                                }).to_h,
                            Cocina::Models::RelatedResource.new({
                                                                  title: [
                                                                    { value: 'My Awesome Research' }
                                                                  ],
                                                                  access: { url: [
                                                                    { value: 'http://my.awesome.research.io' }
                                                                  ] }
                                                                }).to_h
                          ])
    end
  end

  context 'with PURL URIs' do
    let(:work_version) do
      build(:work_version, related_links: [
              build(:related_link, url: 'http://purl.stanford.edu/tx853fp2857'),
              build(:related_link, url: 'https://purl.stanford.edu/xy933bc2222'),
              build(:related_link)
            ])
    end

    it 'creates related links' do
      expect(model).to eq([
                            Cocina::Models::RelatedResource.new({
                                                                  purl: 'https://purl.stanford.edu/tx853fp2857',
                                                                  title: [{ value: 'My Awesome Research' }],
                                                                  access: { digitalRepository: [
                                                                    { value: 'Stanford Digital Repository' }
                                                                  ] }
                                                                }).to_h,
                            Cocina::Models::RelatedResource.new({
                                                                  purl: 'https://purl.stanford.edu/xy933bc2222',
                                                                  title: [{ value: 'My Awesome Research' }],
                                                                  access: { digitalRepository: [
                                                                    { value: 'Stanford Digital Repository' }
                                                                  ] }
                                                                }).to_h,
                            Cocina::Models::RelatedResource.new({
                                                                  title: [{ value: 'My Awesome Research' }],
                                                                  access: { url: [
                                                                    { value: 'http://my.awesome.research.io' }
                                                                  ] }
                                                                }).to_h
                          ])
    end
  end
end
