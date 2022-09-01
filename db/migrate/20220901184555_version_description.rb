class VersionDescription < ActiveRecord::Migration[7.0]
  def change
    rename_column :work_versions, :description, :version_description
  end
end
