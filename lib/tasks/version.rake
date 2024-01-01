# frozen_string_literal: true

require "csv"

desc "Sync work versions with SDR"
# specify a CSV file that contains work druids, one per row (no header),
# and the current work version's version will be synced.
task :sync_version, [:input_filename] => :environment do |_t, args|
  input_filename = args[:input_filename]
  abort "Input CSV file not found" unless File.exist? input_filename

  rows = CSV.read(input_filename).flatten
  num_druids = rows.size
  num_synced = 0

  puts "Locking #{num_druids} works from #{input_filename}"
  rows.each.with_index(1) do |row, i|
    druid = prepend_druid(row)
    puts "#{i} of #{num_druids} works : #{druid}"
    work = Work.find_by(druid:)
    cocina_obj = Repository.find(druid)
    if work && cocina_obj && work.head.version < cocina_obj.version
      work.head.update!(version: cocina_obj.version)
      num_synced += 1
    end
  end

  puts
  puts "#{num_synced} works synced"
end

def prepend_druid(row)
  row.starts_with?("druid:") ? row : row.prepend("druid:")
end
