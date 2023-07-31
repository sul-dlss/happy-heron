# frozen_string_literal: true

require "rails_helper"

RSpec.describe CocinaGenerator::AccessGenerator do
  let(:model) { described_class.generate(work_version:) }
  let(:license_uri) { License.find("CC0-1.0").uri }

  context "when license is none" do
    let(:work_version) { build(:work_version, license: "none") }

    it "generates the model" do
      expect(model).to eq(view: "world",
        download: "world",
        useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context "when access is world" do
    let(:work_version) { build(:work_version) }

    it "generates the model" do
      expect(model).to eq(view: "world",
        download: "world",
        license: license_uri,
        useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context "when access is stanford" do
    let(:work_version) { build(:work_version, access: "stanford") }

    it "generates the model" do
      expect(model).to eq(view: "stanford",
        download: "stanford",
        license: license_uri,
        useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context "when embargoed" do
    let(:work_version) { build(:work_version, :embargoed, access: "world") }

    it "generates the model" do
      expect(model).to eq(view: "citation-only",
        download: "none",
        embargo: {releaseDate: work_version.embargo_date.to_s, view: "world", download: "world"},
        license: license_uri,
        useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context "when embargoed for stanford release" do
    let(:work_version) { build(:work_version, :embargoed, access: "stanford") }

    it "generates the model" do
      expect(model).to eq(view: "citation-only",
        download: "none",
        embargo: {releaseDate: work_version.embargo_date.to_s,
                  view: "stanford",
                  download: "stanford"},
        license: license_uri,
        useAndReproductionStatement: Settings.access.use_and_reproduction_statement)
    end
  end

  context "when access is world and custom rights are provided" do
    let(:work_version) { build(:work_version, :with_custom_rights_statement) }

    it "generates the model" do
      expect(model).to eq(view: "world",
        download: "world",
        license: license_uri,
        useAndReproductionStatement: "An addendum to the built in terms of use #{Settings.access.use_and_reproduction_statement}")
    end
  end
end
