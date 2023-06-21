class AddGlobusToWorkVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :work_versions, :globus, :boolean, default: false, null: false
  end
end
