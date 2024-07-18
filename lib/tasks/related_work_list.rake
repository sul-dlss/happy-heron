# frozen_string_literal: true

desc "Provide a list of all related works' citation text with work and collection info"
task related_work_list: :environment do
  CSV.open('related_works.csv', 'wb') do |csv|
    csv << %w[druid work_title owner collection_title work_type related_work_citation work_id work_version_id]
    RelatedWork.find_each do |related_work|
      work_version = related_work.work_version
      work = work_version.work
      collection = work_version.work.collection
      csv << [work.druid, work_version.title, work.owner.email, collection.head.name, work_version.work_type,
              related_work.citation, work.id, work_version.id]
    end
  end
end
