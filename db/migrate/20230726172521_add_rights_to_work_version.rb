class AddRightsToWorkVersion < ActiveRecord::Migration[7.0]
  def change
    add_column :work_versions, :rights, :string
  end
end
