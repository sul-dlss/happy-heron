# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectionChangeSet do
  let(:collection1) { create(:collection) }
  let(:collection2) do
    create(:collection, email_when_participants_changed: true, email_depositors_status_changed: true,
      review_enabled: true)
  end

  describe "#email_depositors_status_changed_changed?" do
    context "when setting has changed" do
      subject(:result) do
        CollectionChangeSet::PointInTime.new(collection1).diff(collection2).email_depositors_status_changed_changed?
      end

      it { is_expected.to be true }
    end

    context "when setting has not changed" do
      subject(:result) do
        CollectionChangeSet::PointInTime.new(collection1).diff(collection1).email_depositors_status_changed_changed?
      end

      it { is_expected.to be false }
    end
  end

  describe "#email_when_participants_changed_changed?" do
    context "when setting has changed" do
      subject(:result) do
        CollectionChangeSet::PointInTime.new(collection1).diff(collection2).email_when_participants_changed_changed?
      end

      it { is_expected.to be true }
    end

    context "when setting has not changed" do
      subject(:result) do
        CollectionChangeSet::PointInTime.new(collection1).diff(collection1).email_when_participants_changed_changed?
      end

      it { is_expected.to be false }
    end
  end

  describe "#review_enabled_changed?" do
    context "when setting has changed" do
      subject(:result) { CollectionChangeSet::PointInTime.new(collection1).diff(collection2).review_enabled_changed? }

      it { is_expected.to be true }
    end

    context "when setting has not changed" do
      subject(:result) { CollectionChangeSet::PointInTime.new(collection1).diff(collection1).review_enabled_changed? }

      it { is_expected.to be false }
    end
  end
end
