# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionsMailer, type: :mailer do
  let(:collection_version) { build_stubbed(:collection_version, collection: collection) }
  let(:collection_name) { collection_version.name }
  let(:collection) { build_stubbed(:collection) }

  describe '#invitation_to_deposit_email for new user with no name' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).invitation_to_deposit_email }
    let(:collection) { build_stubbed(:collection, :with_depositors) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection_name} collection in the SDR"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Dear New SDR User,')
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection_name} collection")
    end
  end

  describe '#invitation_to_deposit_email for user with a name' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).invitation_to_deposit_email }
    let(:collection) { build_stubbed(:collection, :with_depositors) }

    before { user.update(name: 'Smart Person') }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection_name} collection in the SDR"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('Dear Smart Person,')
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection_name} collection")
    end
  end

  describe '#deposit_access_removed_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).deposit_access_removed_email }

    it 'renders the headers' do
      expect(mail.subject).to eq "Your Depositor permissions for the #{collection_name} " \
                                 'collection in the SDR have been removed'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("A Manager of the #{collection_name} collection has updated the permissions")
    end
  end

  describe '#manage_access_granted_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).manage_access_granted_email }
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
  end

  describe '#manage_access_removed_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).manage_access_removed_email }
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
  end

  describe '#review_access_granted_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).review_access_granted_email }
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
  end

  describe '#review_access_removed_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).review_access_removed_email }
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
  end

  describe '#first_draft_created' do
    let(:user) { build(:user) }
    let(:depositor) { build(:user, name: 'Audre Lorde') }

    let(:mail) do
      described_class.with(user: user, collection_version: collection_version,
                           depositor: depositor).first_draft_created
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "New activity in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{depositor.name} has created a draft"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end
  end

  describe '#item_deposited' do
    let(:user) { build(:user) }
    let(:depositor) { build(:user, name: 'Audre Lorde') }

    let(:mail) do
      described_class.with(user: user, collection_version: collection_version, depositor: depositor).item_deposited
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "New activity in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{depositor.name} has submitted a deposit"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end
  end

  describe '#version_draft_created' do
    let(:user) { build(:user) }
    let(:depositor) { build(:user, name: 'Audre Lorde') }

    let(:mail) do
      described_class.with(user: user, collection_version: collection_version,
                           depositor: depositor).version_draft_created
    end
    let(:collection) { build(:collection) }

    it 'renders the headers' do
      expect(mail.subject).to eq "New activity in the #{collection_name} collection"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match "The Depositor #{depositor.name} has started a new version"
      expect(mail.body.encoded).to match "in the #{collection_name} collection"
    end
  end

  describe '#participants_changed_email' do
    let(:user) { build(:user) }
    let(:mail) { described_class.with(user: user, collection_version: collection_version).participants_changed_email }
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
  end
end
