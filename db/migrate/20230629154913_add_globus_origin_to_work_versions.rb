class AddGlobusOriginToWorkVersions < ActiveRecord::Migration[7.0]
  def change
    add_column :work_versions, :globus_origin, :string, null: true
  end
end
