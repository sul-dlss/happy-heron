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
                                                                  title: [{ value: 'My Awesome Research' }]
                                                                }).to_h,
                            Cocina::Models::RelatedResource.new({
                                                                  purl: 'https://purl.stanford.edu/xy933bc2222',
                                                                  title: [{ value: 'My Awesome Research' }]
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

  context 'with map_related_resources feature flag' do
    before do
      allow(Settings).to receive(:map_related_links_to_resources).and_return(true)
    end

    context 'with external links' do
      let(:work_version) do
        build(:work_version, related_links: [build(:related_link), build(:related_link)])
      end

      it 'creates related resources without titles' do
        expect(model).to eq([
                              Cocina::Models::RelatedResource.new({
                                                                    access: { url: [
                                                                      { value: 'http://my.awesome.research.io' }
                                                                    ] }
                                                                  }).to_h,
                              Cocina::Models::RelatedResource.new({
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
                                                                    purl: 'https://purl.stanford.edu/tx853fp2857'
                                                                  }).to_h,
                              Cocina::Models::RelatedResource.new({
                                                                    purl: 'https://purl.stanford.edu/xy933bc2222'
                                                                  }).to_h,
                              Cocina::Models::RelatedResource.new({
                                                                    access: { url: [
                                                                      { value: 'http://my.awesome.research.io' }
                                                                    ] }
                                                                  }).to_h
                            ])
      end
    end

    context 'with other URIs' do
      let(:work_version) do
        build(:work_version, related_links: [
                build(:related_link, url: 'https://doi.org/10.1126/science.aar3646'),
                build(:related_link, url: 'https://arxiv.org/abs/1706.03762'),
                build(:related_link, url: 'https://pubmed.ncbi.nlm.nih.gov/31060017/')
              ])
      end

      it 'creates related resources' do
        expect(model).to eq([
                              Cocina::Models::RelatedResource.new({
                                                                    identifier: [{
                                                                      uri: 'https://doi.org/10.1126/science.aar3646',
                                                                      type: 'doi'
                                                                    }]
                                                                  }).to_h,
                              Cocina::Models::RelatedResource.new({
                                                                    identifier: [{
                                                                      uri: 'https://arxiv.org/abs/1706.03762',
                                                                      type: 'arxiv'
                                                                    }]
                                                                  }).to_h,
                              Cocina::Models::RelatedResource.new({
                                                                    identifier: [{
                                                                      uri: 'https://pubmed.ncbi.nlm.nih.gov/31060017/',
                                                                      type: 'pmid'
                                                                    }]
                                                                  }).to_h
                            ])
      end
    end
  end
end
