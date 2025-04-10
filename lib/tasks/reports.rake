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

  desc 'Exports druid and SUNet ID of deposit for the current version of each work'
  task depositor_sunetids: :environment do
    druids = File.readlines('druids.txt', chomp: true)

    CSV.open('tmp/depositor_sunetids.csv', 'wb') do |csv|
      csv << %w[druid depositor_sunetid]
      druids.each do |druid|
        druid = "druid:#{druid}" unless druid.start_with?('druid:')
        work = Work.find_by(druid:)
        value = if work.blank?
                  'work not found'
                elsif work&.depositor&.sunetid.blank?
                  'depositor sunetid not found'
                else
                  work.depositor.sunetid
                end
        csv << [druid, value]
      end
    end
  end
end
