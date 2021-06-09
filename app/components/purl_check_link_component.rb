# typed: false
# frozen_string_literal: true

# Renders a widget for describing a related link.
class PurlCheckLinkComponent < ApplicationComponent
  def initialize(work_version:, anchor: nil, label: nil, css_class: nil)
    @work_version = work_version
    @anchor = anchor
    @label = label
    @css_class = css_class
  end

  def choose_label
    return "Choose or Edit #{title}" if label.nil?

    label
  end

  def edit_label
    return "Edit #{title}" if label.nil?

    label
  end

  attr_reader :work_version, :anchor, :label, :css_class

  private

  def title
    WorkTitlePresenter.show(work_version)
  end
end
