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

  describe 'contributors validation' do
    let(:contributor_error) { { contributors: ['Please add at least one contributor.'] } }

    before do
      form.validate(contributors: contributors)
    end

    context 'with no contributors' do
      let(:contributors) { [] }

      it 'does not validate' do
        expect(form.errors.messages).to include(contributor_error)
      end
    end

    context 'with contributors' do
      let(:contributors) do
        [
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'full_name' => 'Stanford', 'role_term' => 'person|Author' },
          { '_destroy' => 'false', 'first_name' => 'Naomi',
            'last_name' => 'Dushay', 'full_name' => 'The Leland Stanford Junior University',
            'role_term' => 'organization|Host institution' }
        ]
      end

      it 'validates with contributors in place' do
        expect(form.errors.messages).not_to include(contributor_error)
      end
    end
  end

  describe 'email validation' do
    it 'does not validate with an invalid contact email' do
      form.validate(contact_email: 'notavalidemail')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ contact_email: ['is invalid'] })
    end

    it 'validates with a correct contact email' do
      form.validate(contact_email: 'avalidemail@test.com')
      expect(form.errors.messages).not_to include({ contact_email: ['is invalid'] })
    end
  end

  describe 'license validation' do
    it 'does not validate with an invalid license' do
      form.validate(license: 'Steal my stuff')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ license: ['is not included in the list'] })
    end

    it 'does not validate with a missing license' do
      form.validate(license: '')
      expect(form).not_to be_valid
      expect(form.errors.messages).to include({ license: ['can\'t be blank', 'is not included in the list'] })
    end

    it 'validates' do
      form.validate(license: License.license_list.first)
      expect(form.errors.messages).not_to include({ license: ['is not included in the list'] })
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
end
