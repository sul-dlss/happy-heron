class AddStateToCollections < ActiveRecord::Migration[6.0]
  def change
    add_column :collections, :state, :string, null: false, default: 'first_draft'
    add_index :collections, :state
  end
end
