# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMailer, type: :mailer do
  let(:collection_version) { build_stubbed(:collection_version, collection:) }
  let(:collection_name) { collection_version.name }
  let(:collection) { build_stubbed(:collection) }
  let(:a_user) { build_stubbed(:user, name: 'Al Dente', first_name: 'Fred') }

  describe '#invitation_to_deposit_email for new user with no name' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user:, collection_version:).invitation_to_deposit_email }
    let(:collection) { build_stubbed(:collection, :with_depositors) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection_name} collection in the SDR"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body with salutation of default name' do
      expect(mail.body.encoded).to match('Dear New SDR User,')
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection_name} collection")
    end
  end

  describe '#invitation_to_deposit_email for user with a name' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user:, collection_version:).invitation_to_deposit_email }
    let(:collection) { build_stubbed(:collection, :with_depositors) }

    before { user.update(name: 'Smart Person', first_name: 'Maxwell') }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection_name} collection in the SDR"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body with salutation of first name' do
      expect(mail.body.encoded).to match('Dear Maxwell,')
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection_name} collection")
    end
  end

  describe '#deposit_access_removed_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).deposit_access_removed_email }

    it 'renders the headers' do
      expect(mail.subject).to eq "Your Depositor permissions for the #{collection_name} " \
                                 'collection in the SDR have been removed'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("A Manager of the #{collection_name} collection has updated the permissions")
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#manage_access_granted_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).manage_access_granted_email }
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You are invited to participate as a Manager in the #{collection_name} " \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('You have been invited to be a Manager ' \
                                         "of the #{collection_name} collection")
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#manage_access_removed_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).manage_access_removed_email }
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Your permissions have changed for the #{collection_name} " \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("A Manager of the #{collection_name} collection has updated the permissions")
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#review_access_granted_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).review_access_granted_email }
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You are invited to participate as a Reviewer in the #{collection_name} " \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('You have been invited to review new deposits ' \
                                         "to the #{collection_name} collection")
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#review_access_removed_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).review_access_removed_email }
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Your permissions have changed for the #{collection_name} " \
                                 'collection in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("A Manager of the #{collection_name} collection has updated the permissions")
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#first_draft_created' do
    let(:user) { a_user }
    let(:owner) { build(:user, name: 'Audre Lorde', first_name: 'Queueueue') }

    let(:mail) do
      described_class.with(user:, collection_version:,
                           owner:).first_draft_created
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Draft item created in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{owner.name} has created a draft"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#first_draft_reminder_email' do
    let(:mail) { described_class.with(collection_version:, user: a_user).first_draft_reminder_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version, state: 'first_draft') }

    it 'renders the mail' do
      exp_subj = "Reminder: Your #{collection_version.name} " \
                 'collection in the SDR is still in progress'
      expect(mail.subject).to eq exp_subj
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']

      expect(mail.body).to include("Dear #{a_user.first_name},")
      expect(mail.body).to match("http://#{Socket.gethostname}/collection_versions/#{collection_version.id}")
    end
  end

  describe '#new_version_reminder_email' do
    let(:mail) { described_class.with(collection_version:, user: a_user).new_version_reminder_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the mail' do
      exp_subj = "Reminder: New version of your #{collection_version.name} " \
                 'collection in the SDR is still in progress'
      expect(mail.subject).to eq exp_subj
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']

      expect(mail.body).to include("Dear #{a_user.first_name},")
      expect(mail.body).to match("http://#{Socket.gethostname}/collection_versions/#{collection_version.id}/edit")
    end
  end

  describe '#item_deposited' do
    let(:user) { a_user }
    let(:owner) { build(:user, name: 'Audre Lorde', first_name: 'Queueueue') }

    let(:mail) do
      described_class.with(user:, collection_version:, owner:).item_deposited
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Item deposit completed in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{owner.name} has submitted a deposit"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#version_draft_created' do
    let(:user) { a_user }
    let(:owner) { build(:user, name: 'Audre Lorde') }

    let(:mail) do
      described_class.with(user:, collection_version:,
                           owner:).version_draft_created
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "New version created in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{owner.name} has started a new version"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe '#participants_changed_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, collection_version:).participants_changed_email }
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Participant changes for the #{collection_name} collection in the SDR"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match 'Members have been either added to or removed from the ' \
                                         "#{collection_name} collection."
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'decommission_manager_email' do
    let(:mail) { described_class.with(user: a_user, collection_version:).decommission_manager_email }
    let(:collection) { build_stubbed(:collection, managed_by: [a_user]) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your collection has been removed from the Stanford Digital Repository'
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders body' do
      expect(mail.body).to include "Dear #{a_user.first_name},"
      expect(mail.body).to include(
        "Your collection \"#{collection_version.name}\" has been removed from the Stanford Digital Repository."
      )
    end
  end
end
