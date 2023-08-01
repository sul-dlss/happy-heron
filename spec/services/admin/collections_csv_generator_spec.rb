# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CollectionsCsvGenerator do
  let(:csv) { described_class.generate([collection]) }

  let(:collection) do
    Collection.new(
      id: 1,
      druid: "druid:cn748wq9511",
      creator: user1,
      managed_by: [user1, user2],
      created_at: Time.zone.parse("2018-01-01"),
      release_option: "depositor-selects",
      release_duration: "6 months",
      access: "world",
      license_option: "required",
      required_license: "CC-BY-4.0",
      default_license: "CC-BY-4.1",
      allow_custom_rights_statement: allow_custom_rights_statement,
      provided_custom_rights_statement: provided_custom_rights_statement,
      custom_rights_statement_custom_instructions: custom_rights_statement_custom_instructions,
      doi_option: "yes",
      review_enabled: true
    )
  end

  let(:allow_custom_rights_statement) { false }
  let(:provided_custom_rights_statement) { nil }
  let(:custom_rights_statement_custom_instructions) { nil }

  let(:collection_version) do
    CollectionVersion.new(
      name: "Collection 1",
      state: "deposited",
      version: 1,
      updated_at: Time.zone.parse("2019-01-01"),
      collection:
    )
  end

  let(:user1) { build(:user, email: "user1@stanford.edu") }
  let(:user2) { build(:user, email: "user2@stanford.edu") }

  before do
    collection.head = collection_version
  end

  context "when a custom rights statement is not allowed" do
    it "generates a CSV" do
      expect(csv).to eq <<~CSV
        collection title,collection id,collection druid,state,version number,creator,managers,date created,date last modified,release setting,release duration,visibility setting,license setting,required license,default license,custom rights allowed,custom rights provided,custom rights instructions,DOI yes/no,review workflow
        Collection 1,1,cn748wq9511,deposited,1,user1,user1; user2,2018-01-01 00:00:00 UTC,2019-01-01 00:00:00 UTC,depositor-selects,6 months,world,required,CC-BY-4.0,CC-BY-4.1,no,no,no,yes,true
      CSV
    end
  end

  context "when a custom rights statement allowed but not provided" do
    let(:allow_custom_rights_statement) { true }

    it "generates a CSV" do
      expect(csv).to eq <<~CSV
        collection title,collection id,collection druid,state,version number,creator,managers,date created,date last modified,release setting,release duration,visibility setting,license setting,required license,default license,custom rights allowed,custom rights provided,custom rights instructions,DOI yes/no,review workflow
        Collection 1,1,cn748wq9511,deposited,1,user1,user1; user2,2018-01-01 00:00:00 UTC,2019-01-01 00:00:00 UTC,depositor-selects,6 months,world,required,CC-BY-4.0,CC-BY-4.1,yes,no,no,yes,true
      CSV
    end
  end

  context "when a custom rights statement allowed and instructions given" do
    let(:allow_custom_rights_statement) { true }
    let(:custom_rights_statement_custom_instructions) { "Some custom instructions" }

    it "generates a CSV" do
      expect(csv).to eq <<~CSV
        collection title,collection id,collection druid,state,version number,creator,managers,date created,date last modified,release setting,release duration,visibility setting,license setting,required license,default license,custom rights allowed,custom rights provided,custom rights instructions,DOI yes/no,review workflow
        Collection 1,1,cn748wq9511,deposited,1,user1,user1; user2,2018-01-01 00:00:00 UTC,2019-01-01 00:00:00 UTC,depositor-selects,6 months,world,required,CC-BY-4.0,CC-BY-4.1,yes,no,yes,yes,true
      CSV
    end
  end

  context "when a custom rights statement is provided" do
    let(:allow_custom_rights_statement) { true }
    let(:provided_custom_rights_statement) { "Some custom rights statement" }

    it "generates a CSV" do
      expect(csv).to eq <<~CSV
        collection title,collection id,collection druid,state,version number,creator,managers,date created,date last modified,release setting,release duration,visibility setting,license setting,required license,default license,custom rights allowed,custom rights provided,custom rights instructions,DOI yes/no,review workflow
        Collection 1,1,cn748wq9511,deposited,1,user1,user1; user2,2018-01-01 00:00:00 UTC,2019-01-01 00:00:00 UTC,depositor-selects,6 months,world,required,CC-BY-4.0,CC-BY-4.1,yes,yes,no,yes,true
      CSV
    end
  end
end
