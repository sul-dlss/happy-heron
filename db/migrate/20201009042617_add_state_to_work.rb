class AddStateToWork < ActiveRecord::Migration[6.0]
  def change
    add_column :works, :state, :string, null: false
    add_index :works, :state
  end
end
