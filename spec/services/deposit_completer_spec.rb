# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepositCompleter do
  subject(:deposit_completer) { described_class.new(object_version:) }

  let(:work) { create(:work, :with_druid) }
  let(:object_version) do
    build(:work_version, state, work:, version_description:)
  end
  let(:state) { :depositing }
  let(:version_description) { "Fixing the title" }

  describe ".complete" do
    let(:instance) { described_class.new(object_version:) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:complete)
    end

    it "invokes #complete on a new instance" do
      described_class.complete(object_version:)
      expect(instance).to have_received(:complete).once
    end
  end

  describe "#object_version" do
    it "has an object version" do
      expect(deposit_completer.object_version).to eq(object_version)
    end
  end

  describe "#parent" do
    context "with a work version" do
      it "returns a work" do
        expect(deposit_completer.parent).to be_a(Work)
      end
    end

    context "with a collection version" do
      let(:object_version) do
        build(:collection_version, state, version_description:)
      end

      it "returns a collection" do
        expect(deposit_completer.parent).to be_a(Collection)
      end
    end
  end

  describe "#complete" do
    context "when object cannot transition to deposit_complete state" do
      let(:state) { :first_draft }

      it "returns nil" do
        expect(deposit_completer.complete).to be_nil
      end
    end

    it "transitions state to deposited" do
      expect { deposit_completer.complete }.to change(object_version, :state).from("depositing").to("deposited")
    end

    it "logs an event as expected" do
      expect { deposit_completer.complete }.to change(Event, :count).by(1)
      expect(Event.last.description).to eq("What changed: #{version_description}")
      expect(Event.last.user.email).to eq("sdr@stanford.edu")
    end
  end
end
