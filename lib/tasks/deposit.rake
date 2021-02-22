# typed: false
# frozen_string_literal: true

desc 'Complete deposit of works and collections (only for development)'
task complete_deposits: :environment do
  abort 'ERROR: This task only runs in the development environment!' unless Rails.env.development?

  objects_awaiting_deposit.each do |object|
    druid = random_druid
    DepositStatusJob.new.complete_deposit(object, druid)
    puts "Marked #{object.class} id=#{object.id} as deposited with #{druid}"
  end
end

def objects_awaiting_deposit
  Collection.with_state('depositing') + WorkVersion.with_state('depositing', 'reserving_purl')
end

def random_druid
  # Use the faker library to generate a random druid using the strict druid
  # regex and only use the trailing 11 characters.
  #
  # Why only the last 11? Observe:
  #
  # > Faker::Base.regexify(DruidTools::Druid.strict_glob)
  # => "{druid:,}qj078cn5200"
  "druid:#{Faker::Base.regexify(DruidTools::Druid.strict_glob).last(11)}"
end
