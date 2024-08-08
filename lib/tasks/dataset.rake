# frozen_string_literal: true

desc 'Create a dataset of articles'
task dataset: :environment do
  # Text article works that have a single file and that file is a PDF.
  # Omits the following collections:
  # * Non-governmental Organizations (NGOs) Collection (2)
  # * Acquisitions Serials (3)
  # * Hopkins Marine Station Collection (5)
  # * Stanford Rare Books and Early Manuscripts (6)
  # * Archive of Recorded Sound/Music Library - Supplemental Materials (8)
  # * John A. Blume Earthquake Engineering Center Technical Report Series (82)
  # * Free EEMs (144)
  # * Rigler and Deutsch Record Index project at Stanford, revisited (155)
  # * Publications and flyers by the Red Guard and mass organizations in Guangdong and other cities (218)

  sql = <<~SQL.squish
    SELECT pdf_blobs.id
    FROM
    (
    SELECT works.id, count(*) AS blobs
    FROM works
    INNER JOIN work_versions ON works.head_id = work_versions.id
    INNER JOIN attached_files ON attached_files.work_version_id=work_versions.id
    INNER JOIN active_storage_attachments ON active_storage_attachments.record_id=attached_files.id
    INNER JOIN active_storage_blobs ON active_storage_attachments.blob_id=active_storage_blobs.id
    WHERE active_storage_blobs.content_type = 'application/pdf'
    AND works.collection_id NOT IN (2,3,5,6,8,82,144,155,218)
    AND work_versions.work_type='text'
    AND work_versions.subtype='{Article}'
    GROUP BY works.id
    HAVING count(*)=1
    ) AS pdf_blobs
    INNER JOIN
    (
    SELECT works.id, count(*) AS blobs
    FROM works
    INNER JOIN work_versions ON works.head_id = work_versions.id
    INNER JOIN attached_files ON attached_files.work_version_id=work_versions.id
    INNER JOIN active_storage_attachments ON active_storage_attachments.record_id=attached_files.id
    INNER JOIN active_storage_blobs ON active_storage_attachments.blob_id=active_storage_blobs.id
    GROUP BY works.id
    HAVING count(*)=1
    ) AS all_blobs
    ON pdf_blobs.id=all_blobs.id;
  SQL

  work_ids = ActiveRecord::Base.connection.execute(sql).values.flatten

  FileUtils.rm_rf('dataset')
  FileUtils.mkdir_p('dataset')

  File.open('dataset/metadata.jsonl', 'w') do |metadata_file|
    work_ids.each do |work_id|
      puts work_id
      work = Work.find(work_id)
      work_version = work.head
      blob = work_version.attached_files.first.file.blob
      pdf_filename = "#{work_id}.pdf"
      blob.open { |file| FileUtils.cp(file.path, "dataset/#{pdf_filename}") }

      metadata = {
        work_id:,
        filename: pdf_filename,
        title: work_version.title,
        abstract: work_version.abstract,
        published_edtf: work_version.published_edtf,
        authors: work_version.authors.map { |contributor| map_contributor(contributor) },
        contributors: work_version.contributors.map { |contributor| map_contributor(contributor) },
        keywords: work_version.keywords.map(&:label)
      }
      metadata_file.write("#{metadata.to_json}\n")
    end
  end
end

def map_contributor(contributor)
  {
    first_name: contributor.first_name,
    last_name: contributor.last_name,
    full_name: contributor.full_name,
    orcid: contributor.orcid
  }
end
