# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkForm do
  subject(:form) { described_class.new(work_version:, work:) }

  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }

  describe 'populator on files' do
    let!(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sul.svg').open,
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
      expect(form.attached_files.first.model.file.blob_id).to eq blob.id
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
      form.validate(contributors:)
      expect(form.contributors.size).to eq 2
      expect(form.contributors.first.full_name).to be_nil
      expect(form.contributors.last.first_name).to be_nil
      expect(form.contributors.last.last_name).to be_nil
    end
  end

  describe 'authors validation' do
    let(:author_error) { 'Please add at least one author.' }

    before do
      form.validate(authors:)
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
        { '_destroy' => 'false', 'email' => 'avalidemail@test.com' },
        { '_destroy' => 'false', 'email' => 'anothervalid@test.com' },
        { '_destroy' => '1', 'email' => 'remove@test.com' },
        { '_destroy' => 'false', 'email' => '' }
      ]
    end

    it 'populates contact emails' do
      form.validate(contact_emails: emails)
      expect(form.contact_emails.map(&:email)).to eq ['avalidemail@test.com', 'anothervalid@test.com']
    end
  end

  describe 'email validation' do
    let(:valid_email) do
      [
        { '_destroy' => 'false', 'email' => 'avalidemail@test.com' },
        { '_destroy' => 'false', 'email' => 'anothervalid@test.com' }
      ]
    end

    it 'validates with a correct contact email' do
      form.validate(contact_emails: valid_email)
      expect(form.contact_emails.size).to eq 2
      expect(form.errors.messages).not_to include({ 'contact_emails.email': ['is invalid'] })
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

    it 'validates with a valid work_type and a "more" type' do
      form.validate(work_type: 'data', subtype: ['Animation'])
      expect(messages).to be_empty
    end

    it 'does not validate with a work_type that requires a user-supplied subtype and is empty' do
      form.validate(work_type: 'other', subtype: [])
      expect(form).not_to be_valid
      expect(messages).to eq ['is not a valid subtype for work type other']
    end

    it 'validates with a valid subtype/work_type combo' do
      form.validate(work_type: 'data', subtype: ['Documentation'])
      expect(messages).to be_empty
    end
  end

  describe 'embargo validation' do
    context 'with a collection that allows depositor to select embargo' do
      let(:errors) { form.errors.where(:embargo_date) }
      let(:messages) { errors.map(&:message) }

      before do
        work.collection = build(:collection, release_option: 'depositor-selects')
      end

      context 'when release is nil' do
        it 'validates' do
          form.validate(release: nil)
          expect(messages).to be_empty
        end
      end

      context 'when release is immediate' do
        it 'validates' do
          form.validate(release: 'immediate')
          expect(messages).to be_empty
        end
      end

      context 'when release is embargo and a date is provided' do
        it 'validates' do
          form.validate(release: 'embargo', 'embargo_date(1i)' => '2040', 'embargo_date(2i)' => '2',
                        'embargo_date(3i)' => '19')
          expect(messages).to be_empty
        end
      end

      context 'when release is embargo and a date is not provided' do
        it 'has an error' do
          form.validate(release: 'embargo', 'embargo_date(1i)' => '2040', 'embargo_date(2i)' => '2')
          expect(messages).to eq ['must provide all date parts and must be a valid date']
        end
      end
    end
  end

  describe 'release validation' do
    context 'with a collection that allows depositor to select embargo' do
      let(:errors) { form.errors.where(:release) }
      let(:messages) { errors.map(&:message) }

      context 'when release has already been set to immediate' do
        let(:collection) { build(:collection, release_option: 'depositor-selects') }
        let(:work_version) { create(:work_version_with_work, :deposited, collection:) }

        context 'when release is nil' do
          it 'validates' do
            form.validate(release: nil)
            expect(messages).to be_empty
          end
        end

        context 'when release is immediate' do
          it 'validates' do
            form.validate(release: 'immediate')
            expect(messages).to be_empty
          end
        end
      end

      context 'when release has already been set to embargo and it elapsed' do
        let(:collection) { build(:collection, release_option: 'depositor-selects') }
        let(:work_version) do
          create(:work_version_with_work, :deposited, embargo_date: 2.weeks.ago, collection:)
        end

        context 'when release is nil' do
          it 'validates' do
            form.validate(release: nil)
            expect(messages).to be_empty
          end
        end

        context 'when release is immediate' do
          it 'validates' do
            form.validate(release: 'immediate')
            expect(messages).to be_empty
          end
        end
      end

      context 'when release has not been set yet' do
        before do
          work.collection = build(:collection, release_option: 'depositor-selects')
        end

        context 'when release is nil' do
          it 'validates' do
            form.validate(release: nil)
            expect(messages).to eq ["can't be blank", 'is not included in the list']
          end
        end

        context 'when release is immediate' do
          it 'validates' do
            form.validate(release: 'immediate')
            expect(messages).to be_empty
          end
        end
      end
    end
  end

  describe 'setting doi' do
    context 'without a druid (a first version)' do
      before do
        work.collection.doi_option = 'depositor-selects'
        form.validate(assign_doi: 'true')
        form.sync
      end

      it 'does not assign a doi' do
        expect(form.model[:work].doi).to be_nil
      end
    end

    context 'when a DOI is requested' do
      before do
        work.collection.doi_option = 'depositor-selects'
        work.druid = 'druid:bc123df4567'
        form.validate(assign_doi: 'true')
        form.sync
      end

      it 'assigns doi' do
        expect(form.model[:work].doi).to eq '10.80343/bc123df4567'
      end
    end

    context 'when the collection specifies DOIs are assigned to all items' do
      before do
        work.collection.doi_option = 'yes'
        work.druid = 'druid:bc123df4567'
        form.sync
      end

      it 'assigns doi' do
        expect(form.model[:work].doi).to eq '10.80343/bc123df4567'
      end
    end
  end

  describe 'file validation' do
    let!(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sul.svg').open,
        filename: 'sul.svg',
        content_type: 'image/svg+xml'
      )
    end
    let(:errors) { form.errors.where(:attached_files) }
    let(:messages) { errors.map(&:message) }

    after do
      blob.destroy
    end

    it 'does not validate when no files and globus is false' do
      form.validate(attached_files: [], globus: false)
      expect(form).not_to be_valid
      expect(messages).to eq ['Please add at least one file.']
    end

    it 'validates when has files and globus is true' do
      form.validate(attached_files: [{ 'label' => 'hello', 'hide' => true, 'file' => blob.signed_id }], globus: true)
      expect(messages).to be_empty
    end

    it 'validates when no files and globus is true' do
      form.validate(attached_files: [], globus: true)
      expect(messages).to be_empty
    end

    it 'validate when has files and globus is false' do
      form.validate(attached_files: [{ 'label' => 'hello', 'hide' => true, 'file' => blob.signed_id }], globus: false)
      expect(messages).to be_empty
    end
  end
end
