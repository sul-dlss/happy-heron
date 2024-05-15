# frozen_string_literal: true

desc 'Provide a list of all files in H2 and associated work information'
task file_list: :environment do
  CSV.open('works_files_list.csv', 'wb') do |csv|
    csv << %w[druid title filename description]
    deposited_current_versions.each do |work_version|
      work_version.attached_files.each do |attached_file|
        csv << [work_version.work.druid, work_version.title, attached_file.filename, attached_file.label]
      end
    end
  end
end

def deposited_current_versions
  WorkVersion.with_state(:deposited).joins(:work).where('works.head_id = work_versions.id')
end
