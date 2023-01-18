# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorksMailer do
  let(:work_depositor) { build_stubbed(:user, email: work.depositor.email, name: 'Al Dente', first_name: 'Fred') }
  let(:a_user) { build(:user, name: 'Al Dente', first_name: 'Fred') }
  let(:b_user) { build(:user, name: 'Overcooked', first_name: 'Fred') }

  describe 'reject_email' do
    let(:user) { work_depositor }
    let(:mail) { described_class.with(user:, work_version:).reject_email }
    let(:work) do
      create(:work, collection:,
                    events: [build(:event, event_type: 'reject', description: 'Add something to make it pop.')])
    end
    let(:work_version) { build_stubbed(:work_version, :rejected, work:) }
    let(:collection) { create(:collection, head: collection_version) }
    let(:collection_version) { create(:collection_version, name: 'gastropub humblebrag taiyaki') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and returned'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match('Add something to make it pop.')
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'deposited_email' do
    let(:user) { work_depositor }
    let(:mail) { described_class.with(user:, work_version:).deposited_email }
    let(:work) { build_stubbed(:work, collection:, druid: 'druid:bc123df4567', doi: '10.001/bc123df4567') }
    let(:work_version) { build_stubbed(:work_version, :deposited, title: 'Photo booth activated charcoal', work:) }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version, name: 'gastropub humblebrag taiyaki') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit, Photo booth activated charcoal, is published in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content('“Photo booth activated charcoal”')
      expect(mail.body.encoded).to have_content('gastropub humblebrag taiyaki collection')
      expect(mail.body.encoded).to have_content('https://doi.org/10.001/bc123df4567')
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'new_version_deposited_email' do
    let(:user) { work_depositor }
    let(:mail) { described_class.with(user:, work_version:).new_version_deposited_email }
    let(:work) { build_stubbed(:work, collection:, druid: 'druid:bc123df4567', doi: '10.001/bc123df4567') }
    let(:work_version) { build_stubbed(:work_version, :deposited, title: 'twee retro man braid', work:) }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version, name: 'listicle fam ramps flannel') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'A new version of twee retro man braid has been deposited in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content('“twee retro man braid”')
      expect(mail.body.encoded).to have_content('listicle fam ramps flannel')
      expect(mail.body.encoded).to have_content('https://doi.org/10.001/bc123df4567')
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'approved_email' do
    let(:user) { work_depositor }
    let(:mail) { described_class.with(user:, work_version:).approved_email }
    let(:work) { build_stubbed(:work, collection:, druid: 'druid:bc123df4567', doi: '10.001/bc123df4567') }
    let(:work_version) { build_stubbed(:work_version, :deposited, title: 'Hammock kombucha mustache', work:) }
    let(:collection) { build_stubbed(:collection, :with_reviewers, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version, name: 'Farm-to-table beard aesthetic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and approved'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to have_content('“Hammock kombucha mustache”')
      expect(mail.body.encoded).to have_content('Farm-to-table beard aesthetic collection')
      expect(mail.body.encoded).to have_content('https://doi.org/10.001/bc123df4567')
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'submitted_email' do
    let(:user) { a_user }
    let(:mail) { described_class.with(user:, work_version:).submitted_email }
    let(:work) { build_stubbed(:work, collection:, depositor: user) }
    let(:work_version) do
      build_stubbed(:work_version, :pending_approval, title: 'Tiramisu lemon drops chocolate cake', work:)
    end

    let(:collection) { build_stubbed(:collection, :with_reviewers, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version, name: 'small batch organic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit is submitted and waiting for approval'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match 'Your deposit, “Tiramisu lemon drops chocolate cake” to the ' \
                                         "small batch organic\r\n  collection in the Stanford Digital Repository, " \
                                         'is now waiting for review by a collection Manager.'
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end
  end

  describe 'first_draft_reminder_email' do
    let(:work) { build_stubbed(:work, collection:, depositor: a_user, owner: b_user) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:).first_draft_reminder_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers for the owner (not the depositor)' do
      expect(mail.subject).to eq "Reminder: Deposit to the #{work.collection_name} collection in the SDR is in progress"
      expect(mail.to).to eq [work.owner.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders a link to edit the draft in the body' do
      expect(mail.body).to match("http://#{Socket.gethostname}/works/#{work.id}/edit")
    end

    it 'salutation uses work.owner.first_name' do
      expect(mail.body).to include("Dear #{work.owner.first_name},")
      expect(mail.body).not_to include("Dear #{work.owner.name},")
    end
  end

  describe 'new_version_reminder_email' do
    let(:work) { build_stubbed(:work, collection:, depositor: a_user, owner: a_user) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:).new_version_reminder_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      exp_subj = "Reminder: New version of a deposit to the #{work.collection_name} " \
                 'collection in the SDR is in progress'
      expect(mail.subject).to eq exp_subj
      expect(mail.to).to eq [work.owner.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'salutation uses work.owner.first_name' do
      expect(mail.body).to include("Dear #{work.owner.first_name},")
      expect(mail.body).not_to include("Dear #{work.owner.name},")
    end

    it 'renders a link to edit the draft in the body' do
      expect(mail.body).to match("http://#{Socket.gethostname}/works/#{work.id}/edit")
    end
  end

  describe 'changed_owner_email' do
    let(:work) { build_stubbed(:work, collection:, owner: a_user, head: work_version) }
    let(:work_version) { build_stubbed(:work_version) }
    let(:mail) { described_class.with(work:).changed_owner_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You now have access to an item in the SDR'
      expect(mail.to).to eq [work.owner.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'salutation uses work.owner.first_name' do
      expect(mail.body).to include("Dear #{work.owner.first_name},")
      expect(mail.body).not_to include("Dear #{work.owner.name},")
    end

    it 'renders body' do
      expect(mail.body).to include "You are now the owner of the item \"#{work_version.title}\""
      expect(mail.body).to match("http://#{Socket.gethostname}/works/#{work.id}")
    end
  end

  describe 'changed_owner_collection_manager_email' do
    let(:work) { build_stubbed(:work, collection:, head: work_version) }
    let(:work_version) { build_stubbed(:work_version) }
    let(:mail) { described_class.with(work:, user: a_user).changed_owner_collection_manager_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'The ownership of an item in your collection has changed'
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{a_user.first_name},")
      expect(mail.body).not_to include("Dear #{a_user.name},")
    end

    it 'renders body' do
      expect(mail.body).to include "Ownership of the item \"#{work_version.title}\""
      expect(mail.body).to match("http://#{Socket.gethostname}/works/#{work.id}")
    end
  end

  describe 'globus_deposited_email' do
    let(:work) { build_stubbed(:work, collection:, depositor: a_user, owner: a_user) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:).globus_deposited_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'User has deposited an item with files on Globus'
      expect(mail.to).to eq ['h2-administrators@lists.stanford.edu']
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders body' do
      expect(mail.body).to include 'The following item has been deposited'
      expect(mail.body).to match("http://#{Socket.gethostname}/works/#{work.id}")
      expect(mail.body).to match("http://#{Socket.gethostname}/collections/#{collection.id}")
      expect(mail.body).to include a_user.name
    end
  end

  describe 'decommission_owner_email' do
    let(:work) { build_stubbed(:work, collection:, owner: a_user) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:).decommission_owner_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your item has been removed from the Stanford Digital Repository'
      expect(mail.to).to eq [work.owner.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'salutation uses work.owner.first_name' do
      expect(mail.body).to include("Dear #{work.owner.first_name},")
      expect(mail.body).not_to include("Dear #{work.owner.name},")
    end

    it 'renders body' do
      expect(mail.body).to include
      "Your item \"#{work_version.title}\" has been removed from the Stanford Digital Repository."
    end
  end

  describe 'decommission_manager_email' do
    let(:work) { build_stubbed(:work, collection:) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:, user: a_user).decommission_manager_email }
    let(:collection) { build_stubbed(:collection, head: collection_version) }
    let(:collection_version) { build_stubbed(:collection_version) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'An item in your collection has been removed from the Stanford Digital Repository'
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders body' do
      expect(mail.body).to include "Dear #{a_user.first_name},"
      expect(mail.body).to include(
        "The item \"#{work_version.title}\" in your collection MyString has been removed"
      )
    end
  end

  describe 'globus_account_setup' do
    let(:work) { build_stubbed(:work) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:, user: a_user).globus_account_setup }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Activate your Globus account'
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders body' do
      expect(mail.body).to include "Dear #{a_user.first_name},"
      expect(mail.body).to include 'Click the link below and follow the instructions to access Globus'
    end
  end

  describe 'globus_endpoint_created' do
    let(:work) { build_stubbed(:work) }
    let(:work_version) { build_stubbed(:work_version, work:) }
    let(:mail) { described_class.with(work_version:, user: a_user).globus_endpoint_created }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Upload your files to the SDR using Globus'
      expect(mail.to).to eq [a_user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders body' do
      expect(mail.body).to include "Dear #{a_user.first_name},"
      expect(mail.body).to include 'Please transfer your files to the above location in Globus'
    end
  end
end
