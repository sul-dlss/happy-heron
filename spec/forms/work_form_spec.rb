# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  subject(:form) { described_class.new(work) }

  let(:work) { build(:work) }

  describe 'populator on files' do
    let!(:blob) do
      ActiveStorage::Blob.create_after_upload!(
        io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
        filename: 'sul.svg',
        content_type: 'image/svg+xml'
      )
    end

    after do
      blob.destroy
    end

    it 'populates attached_files' do
      form.validate(attached_files: [{ 'label' => 'hello', 'hide' => true, 'file' => blob.signed_id }])

      expect(form.attached_files.size).to eq 1
      expect(form.attached_files.first.label).to eq 'hello'
      expect(form.attached_files.first.hide).to be true
      expect(form.attached_files.first.file).to eq blob.signed_id
    end
  end

  describe 'year validation' do
    let(:current_year) { Time.zone.today.year }

    %w[published(1i) created(1i) created_range(1i) created_range(4i)].each do |attribute|
      before { form.validate(attribute => year, keywords: [{ label: 'foo' }]) }

      context "with a four-digit integer <= the current year as #{attribute}" do
        let(:year) { current_year - 1 }

        it { is_expected.to be_valid }
      end

      context "with a four-digit integer > the current year as #{attribute}" do
        let(:year) { current_year + 1 }

        it { is_expected.not_to be_valid }
      end

      context "with a < four-digit integer as #{attribute}" do
        let(:year) { 999 }

        it { is_expected.not_to be_valid }
      end

      context 'with a string' do
        let(:year) { current_year.to_s }

        it { is_expected.to be_valid }
      end

      context 'with a float' do
        let(:year) { current_year.to_f }

        it { is_expected.to be_valid }
      end
    end
  end
end
