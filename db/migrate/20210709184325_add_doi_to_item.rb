class AddDoiToItem < ActiveRecord::Migration[6.1]
  def change
    add_column :works, :assign_doi, :boolean, default: false, null: false
    add_column :works, :doi, :string
  end
end
