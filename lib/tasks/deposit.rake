# frozen_string_literal: true

desc 'Complete deposit of works and collections (only for development)'
task complete_deposits: :environment do
  abort 'ERROR: This task only runs in the development environment!' unless Rails.env.development?

  objects_awaiting_deposit.each do |object_version|
    deposit_completer = DepositCompleter.new(object_version:)
    druid = deposit_completer.parent.druid.presence || random_druid
    deposit_completer.parent.update(druid:)
    deposit_completer.complete
    puts "Marked #{object_version.class} id=#{object_version.id} as deposited with #{druid}"
  end
end

desc 'Complete the assignment of a druid to purl reservation works that need one'
task assign_pids: :environment do
  abort 'ERROR: This task only runs in the development environment!' unless Rails.env.development?

  WorkVersion.with_state('reserving_purl').each do |object|
    druid = random_druid
    object.work.update(druid:)
    object.pid_assigned!
    puts "Assigned #{druid} to #{object.title} (id=#{object.id})"
  end
end

def objects_awaiting_deposit
  CollectionVersion.with_state('depositing') + WorkVersion.with_state('depositing')
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
