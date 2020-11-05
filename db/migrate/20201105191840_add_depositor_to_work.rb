class AddDepositorToWork < ActiveRecord::Migration[6.0]
  def change
    add_reference :works, :depositor, null: false, foreign_key: { to_table: :users }
  end
end
