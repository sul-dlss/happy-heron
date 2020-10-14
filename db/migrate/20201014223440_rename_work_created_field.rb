class RenameWorkCreatedField < ActiveRecord::Migration[6.0]
  def change
    rename_column :works, :created_etdf, :created_edtf
  end
end
