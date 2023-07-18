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
end
