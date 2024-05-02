class AddUserVersionToWorkVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :work_versions, :user_version, :integer
    add_index :work_versions, [:work_id, :user_version], unique: true
    Work.all.each { |work| work.head.update(user_version: 1) }
  end
end
