class RemoveUniqueFromWorkVersion < ActiveRecord::Migration[7.0]
  def change
    remove_index :work_versions, [:work_id, :user_version]
    WorkVersion.where.not(state: 'version_draft').update_all(user_version: 1)
    WorkVersion.where(state: 'version_draft').update_all(user_version: nil)
  end
end
