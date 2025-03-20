# frozen_string_literal: true

namespace :reports do
  desc 'Exports work type and subtypes of current version of each work'
  task work_types: :environment do
    CSV.open('tmp/work_types.csv', 'wb') do |csv|
      csv << %w[work_id title work_type work_subtypes state]
      Work.find_each do |work|
        work_version = work.head
        csv << [work.id, work_version.title, work_version.work_type, work_version.subtype&.join('|'),
                work_version.state]
      end
    end
  end
end
