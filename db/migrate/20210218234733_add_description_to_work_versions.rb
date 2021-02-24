class AddDescriptionToWorkVersions < ActiveRecord::Migration[6.1]
  def change
    add_column :work_versions, :description, :string
  end
end
