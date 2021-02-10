class CreateWorkVersions < ActiveRecord::Migration[6.1]
  def change
    rename_table :works, :work_versions

    create_table :works do |t|
      t.string :druid
      t.references :head, foreign_key: { to_table: :work_versions }
      t.references :collection, foreign_key: true
      t.references :depositor, foreign_key: { to_table: :users }
      t.timestamps
      t.index :druid, unique: true
    end

    add_reference :work_versions, :work, foreign_key: true

    WorkVersion.all.each do |version|
      work = Work.find_or_initialize_by(druid: version.druid)
      work.update(collection_id: version.collection_id,
                  depositor: version.depositor_id,
                  head_id: version.id)
      version.update(work: work)
    end

    remove_column :work_versions, :druid, :string
    remove_reference :work_versions, :depositor
    remove_reference :work_versions, :collection

    change_column_null :work_versions, :work_id, false

    rename_column :related_works, :work_id, :work_version_id
    rename_column :abstract_contributors, :work_id, :work_version_id
    rename_column :attached_files, :work_id, :work_version_id
    rename_column :keywords, :work_id, :work_version_id
  end
end
