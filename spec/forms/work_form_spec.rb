# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  subject(:form) { described_class.new(work) }

  let(:work) { build(:work) }

  describe 'populator on files' do
    let!(:blob) do
      ActiveStorage::Blob.create_and_upload!(
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

  describe 'authors validation' do
    let(:author_error) { 'Please add at least one author.' }

    before do
      form.validate(authors: authors)
    end

    context 'with no authors' do
      let(:authors) { [] }

      it 'does not validate' do
        expect(form.errors.where(:authors).first.message).to include(author_error)
      end
    end

    context 'with authors' do
      let(:authors) do
        [
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'full_name' => 'Stanford', 'role_term' => 'person|Author' },
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'full_name' => 'The Leland Stanford Junior University',
            'role_term' => 'organization|Host institution' }
        ]
      end
      let(:errors) { form.errors.where(:authors) }

      it 'validates with authors in place' do
        expect(errors).to be_empty
      end
    end
  end

  describe 'populator on contact email' do
    let(:emails) do
      [
        { '_destroy': 'false', 'email': 'avalidemail@test.com' },
        { '_destroy': 'false', 'email': 'anothervalid@test.com' },
        { '_destroy': 'false', 'email': 'third@example.com' }
      ]
    end

    it 'populates contact emails' do
      form.validate(contact_emails: emails)
      expect(form.contact_emails.size).to be 3
    end
  end

  describe 'email validation' do
    let(:invalid_email) do
      [
        { '_destroy': 'false', 'email': 'notavalidemail' }
      ]
    end
    let(:valid_email) do
      [
        { '_destroy': 'false', 'email': 'avalidemail@test.com' },
        { '_destroy': 'false', 'email': 'anothervalid@test.com' }
      ]
    end

    it 'does not validate with an invalid contact email' do
      form.validate(contact_emails: invalid_email)
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ "contact_emails.email": ['is invalid'] })
    end

    it 'validates with a correct contact email' do
      form.validate(contact_emails: valid_email)
      expect(form.contact_emails.size).to eq 2
      expect(form.errors.messages).not_to include({ "contact_emails.email": ['is invalid'] })
    end
  end

  describe 'license validation' do
    let(:errors) { form.errors.where(:license) }
    let(:messages) { errors.map(&:message) }

    it 'does not validate with an invalid license' do
      form.validate(license: 'Steal my stuff')
      expect(form).not_to be_valid
      expect(messages).to eq ['is not included in the list']
    end

    it 'does not validate with a missing license' do
      form.validate(license: '')
      expect(form).not_to be_valid
      expect(messages).to eq ['can\'t be blank', 'is not included in the list']
    end

    it 'validates' do
      form.validate(license: License.license_list.first)
      expect(errors).to be_empty
    end
  end

  describe 'type validation' do
    let(:errors) { form.errors.where(:work_type) }
    let(:messages) { errors.map(&:message) }

    it 'does not validate with an invalid work type' do
      form.validate(work_type: 'a pile of something')
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid work type']
    end

    it 'does not validate with a missing work type' do
      form.validate(work_type: '')
      expect(form).not_to be_valid
      expect(messages).to eq ['can\'t be blank', 'is not a valid work type']
    end
  end

  describe 'subtype validation' do
    let(:errors) { form.errors.where(:subtype) }
    let(:messages) { errors.map(&:message) }

    it 'does not validate with an invalid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Animation'])
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid subtype for work type data']
    end

    it 'does not validate with a work_type that requires a user-supplied subtype and is empty' do
      form.validate(work_type: 'other', subtype: [])
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid subtype for work type other']
    end

    it 'validates with a valid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Software/code'])
      expect(messages).to be_empty
    end
  end
end
