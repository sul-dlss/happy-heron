# frozen_string_literal: true

require "rails_helper"

RSpec.describe Works::AvailableDateComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(nil, work_form, controller.view_context, {}) }
  let(:work) { work_version.work }
  let(:work_version) { build(:work_version) }
  let(:work_form) { WorkForm.new(work_version:, work:) }
  let(:rendered) { render_inline(described_class.new(form:)) }

  before do
    work_form.prepopulate!
  end

  it "checks the immediate release radio button by default" do
    expect(rendered.css("#release_immediate[@checked]")).to be_present
    expect(rendered.css("#release_embargo[@checked]")).not_to be_present
  end

  it "requires all of the date fields to be filled in" do
    expect(rendered.css("#work_embargo_year[required]")).to be_present
    expect(rendered.css("#work_embargo_month[required]")).to be_present
    expect(rendered.css("#work_embargo_day[required]")).to be_present
  end

  context "when the embargo date is set" do
    let(:embargo_date) { work_version.embargo_date }
    let(:work_version) { build(:work_version, :embargoed) }

    it "checks the embargo release radio button" do
      expect(rendered.css("#release_embargo[@checked]")).to be_present
      expect(rendered.css("#release_immediate[@checked]")).not_to be_present
    end

    it "renders the year" do
      expect(rendered.css("#work_embargo_year option[@selected]").first["value"])
        .to eq embargo_date.year.to_s
    end

    it "renders the month" do
      expect(rendered.css("#work_embargo_month option[@selected]").first["value"])
        .to eq embargo_date.month.to_s
    end

    it "renders the day" do
      expect(rendered.css("#work_embargo_day option[@selected]").first["value"])
        .to eq embargo_date.day.to_s
    end
  end

  context "when the embargo date is provided by embargo fields" do
    before do
      work_form.validate({
        release: "embargo",
        "embargo_date(1i)": DateTime.now.year.to_s,
        "embargo_date(2i)": "12",
        "embargo_date(3i)": "31"
      })
    end

    it "checks the embargo release radio button" do
      expect(rendered.css("#release_embargo[@checked]")).to be_present
      expect(rendered.css("#release_immediate[@checked]")).not_to be_present
    end

    it "renders the year" do
      expect(rendered.css("#work_embargo_year option[@selected]").first["value"])
        .to eq DateTime.now.year.to_s
    end

    it "renders the month" do
      expect(rendered.css("#work_embargo_month option[@selected]").first["value"])
        .to eq "12"
    end

    it "renders the day" do
      expect(rendered.css("#work_embargo_day option[@selected]").first["value"])
        .to eq "31"
    end
  end

  context "when there is an error" do
    let(:work_version) { build(:work_version, :embargoed) }

    before do
      work_form.errors.add(:embargo_date, "Must be less than 3 years in the future")
    end

    it "renders the message and adds invalid styles" do
      expect(rendered.css(".is-invalid ~ .invalid-feedback").text).to eq "Must be less than 3 years in the future"
      expect(rendered.css("#work_embargo_year.is-invalid")).to be_present
      expect(rendered.css("#work_embargo_month.is-invalid")).to be_present
      expect(rendered.css("#work_embargo_day.is-invalid")).to be_present
    end
  end
end
