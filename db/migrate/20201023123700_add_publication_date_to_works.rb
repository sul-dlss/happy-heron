class AddPublicationDateToWorks < ActiveRecord::Migration[6.0]
  def change
    add_column :works, :published_edtf, :string, null: true
    change_column_null :works, :created_edtf, true
  end
end
