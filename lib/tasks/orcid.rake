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
end
