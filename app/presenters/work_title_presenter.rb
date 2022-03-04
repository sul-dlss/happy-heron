# frozen_string_literal: true

# A helper for displaying a title for a Work
class WorkTitlePresenter
  def self.show(work_version)
    work_version&.title.presence || 'No title'
  end
end
