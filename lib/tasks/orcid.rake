namespace :orcid do
  desc "Returns Stanford users with read-limited permissions"
  task read_limited: :environment do
    orcid_users = OrcidReadLimitedUserService.execute
    CSV.open("read_limited.csv", "wb") do |csv|
      csv << ["sunetid", "orcidid"]
      orcid_users.each do |orcid_user|
        csv << [orcid_user.sunetid, orcid_user.orcidid]
        puts "#{orcid_user.sunetid} => #{orcid_user.orcidid}"
      end
    end
  end

  desc "Returns Stanford users not found in MAIS"
  task stanford_users: :environment do
    contributors = OrcidStanfordUserService.execute
    CSV.open("stanford_users.csv", "wb") do |csv|
      csv << ["first name", "last name", "orcidid"]
      contributors.each do |contributor|
        csv << [contributor.first_name, contributor.last_name, contributor.orcid]
        puts "#{contributor.first_name} #{contributor.last_name} => #{contributor.orcid}"
      end
    end
  end

  desc "Creates/updates Orcid works for all works in a collection"
  task :collection, %i[id] => :environment do |_task, args|
    # Note that DSA will figure out which works actually need to have Orcid works created/updated.
    # Some will not orcids or orcids will not be for Stanford researchers or researchers will
    # not have given permission to update their orcid records or the orcid work may not need to be updated.
    client = Dor::Services::Client.configure(url: Settings.dor_services.url,
      token: Settings.dor_services.token)
    works = Work.where(collection_id: args[:id].to_i).where.not(druid: nil)
    works.each do |work|
      puts "Maybe updating #{work.druid}"
      client.object(work.druid).update_orcid_work
    end
  end
end
