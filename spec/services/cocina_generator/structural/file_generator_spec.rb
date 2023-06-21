# frozen_string_literal: true

require "rails_helper"

RSpec.describe CocinaGenerator::Structural::FileGenerator do
  let(:model) { described_class.generate(work_version:, attached_file:, resource_id: "1234", cocina_file: nil) }

  describe "#access" do
    subject { model.access }

    context "when file is visible" do
      let(:attached_file) { create(:attached_file, :with_file, work_version:) }

      context "when work is public" do
        let(:work_version) { build(:work_version) }

        it { is_expected.to eq Cocina::Models::FileAccess.new(view: "world", download: "world") }
      end

      context "when work is stanford-only" do
        let(:work_version) { build(:work_version, access: "stanford") }

        it { is_expected.to eq Cocina::Models::FileAccess.new(view: "stanford", download: "stanford") }
      end
    end

    context "when file is hidden" do
      let(:work_version) { build(:work_version) }
      let(:attached_file) { create(:attached_file, :with_file, work_version:, hide: true) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(view: "world", download: "world") }
    end

    context "when object is embargoed" do
      let(:work_version) { build(:work_version, :embargoed) }
      let(:attached_file) { create(:attached_file, :with_file, work_version:, hide: true) }

      it { is_expected.to eq Cocina::Models::FileAccess.new(view: "dark", download: "none") }
    end
  end

  describe "#initialize" do
    context "when neither resource_id nor file cocina is provided" do
      let(:work_version) { build(:work_version) }
      let(:attached_file) { create(:attached_file, :with_file, work_version:) }

      it "raises an error" do
        expect do
          described_class.generate(work_version:, attached_file:, resource_id: nil,
            cocina_file: nil)
        end.to raise_error("Either resource_id or cocina_file should be provided.")
      end
    end
  end

  describe "#filename" do
    context "when attached file has a path" do
      let(:work_version) { build(:work_version) }
      let(:attached_file) { create(:attached_file, :with_file, work_version:, path: "test/file.txt") }

      it "uses the path" do
        expect(model.filename).to eq "test/file.txt"
      end
    end

    context "when attached file does not have a path" do
      let(:work_version) { build(:work_version) }
      let(:attached_file) { create(:attached_file, :with_file, work_version:, path: nil) }

      it "uses the file filename" do
        expect(model.filename).to eq "sul.svg"
      end
    end
  end
end
