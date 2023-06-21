# frozen_string_literal: true

require "csv"

desc "Lock specified works"
# specify a CSV file that contains work druids, one per row (no header), and each work will be locked
#  (if not already locked)
task :lock_works, [:input_filename] => :environment do |_t, args|
  input_filename = args[:input_filename]
  abort "Input CSV file not found" unless File.exist? input_filename

  rows = CSV.read(input_filename).flatten
  num_druids = rows.size
  num_locked = 0

  puts "Locking #{num_druids} works from #{input_filename}"
  rows.each.with_index(1) do |row, i|
    puts "#{i} of #{num_druids} works : #{row}"
    work = Work.find_by(druid: prepend_druid(row))
    if work && !work.locked
      work.update(locked: true)
      num_locked += 1
    end
  end

  puts
  puts "#{num_locked} works locked"
end

desc "Lock all works in specified collections"
# specify a CSV file that contains collection druids, one per row (no header), and each work
#  in each collection will be locked (if not already locked)
task :lock_collections, [:input_filename] => :environment do |_t, args|
  input_filename = args[:input_filename]
  abort "Input CSV file not found" unless File.exist? input_filename

  rows = CSV.read(input_filename).flatten
  num_druids = rows.size
  num_locked = 0

  puts "Locking #{num_druids} collections from #{input_filename}"
  rows.each.with_index(1) do |row, i|
    puts "#{i} of #{num_druids} collections : #{row}"
    collection = Collection.find_by(druid: prepend_druid(row))
    if collection
      works = collection.works.where("druid is not ?", nil) # only lock works in this collection with a druid
      num_works = works.size
      works.each.with_index(1) do |work, j|
        puts "...#{j} of #{num_works} works : #{work.druid}"
        unless work.locked
          work.update(locked: true)
          num_locked += 1
        end
      end
    end
  end

  puts
  puts "#{num_locked} works locked across #{num_druids} collections"
end

def prepend_druid(row)
  row.starts_with?("druid:") ? row : row.prepend("druid:")
end
