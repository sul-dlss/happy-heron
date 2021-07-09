class AddDoiOptionToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :doi_option, :string, default: 'depositor-selects'
  end
end
