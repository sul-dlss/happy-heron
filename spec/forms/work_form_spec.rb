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

  describe 'populator on contributors' do
    let(:contributors) do
      [
        { '_destroy' => '1', 'first_name' => 'Justin',
          'last_name' => 'Coyne', 'role_term' => 'person|Data collector' },
        { '_destroy' => 'false', 'first_name' => 'Naomi',
          'last_name' => 'Dushay', 'full_name' => 'Stanford', 'role_term' => 'person|Author' },
        { '_destroy' => 'false', 'first_name' => 'Naomi',
          'last_name' => 'Dushay', 'full_name' => 'The Leland Stanford Junior University',
          'role_term' => 'organization|Host institution' }
      ]
    end

    it 'filters out name values for the wrong type' do
      form.validate(contributors: contributors)
      expect(form.contributors.size).to eq 2
      expect(form.contributors.first.full_name).to be_nil
      expect(form.contributors.last.first_name).to be_nil
      expect(form.contributors.last.last_name).to be_nil
    end
  end

  describe 'email validation' do
    it 'does not validate with an invalid contact email' do
      form.validate(contact_email: 'notavalidemail')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ contact_email: ['is invalid'] })
    end
  end

  describe 'type and subtype validation' do
    it 'does not validate with an invalid work type' do
      form.validate(work_type: 'a pile of something')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ work_type: ['is not a valid work type'] })
    end

    it 'does not validate with a missing work type' do
      form.validate(work_type: '')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ work_type: ['can\'t be blank', 'is not a valid work type'] })
    end

    it 'does not validate with an invalid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Animation'])
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ subtype: ['is not a valid subtype for work type data'] })
    end

    it 'does not validate with a work_type that requires a user-supplied subtype and is empty' do
      form.validate(work_type: 'other', subtype: [])
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ subtype: ['is not a valid subtype for work type other'] })
    end

    it 'validates with a valid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Software/code'])
      expect(form.errors.messages).not_to include({ subtype: ['is not a valid subtype for work type data'] })
    end
  end

  describe 'year validation' do
    let(:current_year) { Time.zone.today.year }

    %w[published(1i) created(1i) created_range(1i) created_range(4i)].each do |attribute|
      before { form.validate(attribute => year, keywords: [{ label: 'foo' }], attached_files: [{ label: 'bar' }]) }

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
