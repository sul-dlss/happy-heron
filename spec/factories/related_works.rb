# frozen_string_literal: true

FactoryBot.define do
  factory :related_work do
    citation do
      "Giarlo, M.J. (2013). Academic Libraries as Data Quality Hubs. " \
        "Journal of Librarianship and Scholarly Communication, 1(3)."
    end
    work_version
  end
end
