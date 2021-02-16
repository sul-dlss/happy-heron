class WorkVersionDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :work_versions, :version, 1
  end
end
