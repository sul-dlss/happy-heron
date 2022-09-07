# frozen_string_literal: true

# NOTE: This task is largely copypasta from the DepositStatusJob, with the logic
#       divorced from any messaging or background job frameworks. We could
#       consider extracting the common bits to a service?
desc 'Complete deposit of works and collections (only for development)'
task complete_deposits: :environment do
  abort 'ERROR: This task only runs in the development environment!' unless Rails.env.development?

  objects_awaiting_deposit.each do |object_version|
    druid = random_druid
    parent = case object_version
             when CollectionVersion
               object_version.collection
             when WorkVersion
               object_version.work
             end
    parent.update(druid: druid)

    what_changed = object_version.version_description.presence || 'not specified'
    # NOTE: This user is created when seeding the database, a common practice running in dev.
    parent.event_context = { user: User.find_by(name: 'SDR'), description: "What changed: #{what_changed}" }

    object_version.deposit_complete!
    puts "Marked #{object_version.class} id=#{object_version.id} as deposited with #{druid}"
  end
end

desc 'Complete the assignment of a druid to purl reservation works that need one'
task assign_pids: :environment do
  abort 'ERROR: This task only runs in the development environment!' unless Rails.env.development?

  WorkVersion.with_state('reserving_purl').each do |object|
    druid = random_druid
    object.work.update(druid: druid)
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
