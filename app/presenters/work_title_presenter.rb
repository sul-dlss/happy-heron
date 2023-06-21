# frozen_string_literal: true

# A helper for displaying a title for a Work
class WorkTitlePresenter
  def self.show(work_version)
    work_version.title.presence || I18n.t("deposit.no_title")
  end
end
