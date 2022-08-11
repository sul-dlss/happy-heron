class AddOwnerToWorks < ActiveRecord::Migration[7.0]
  def change
    change_table(:works) do |t|
      t.references :owner, foreign_key: { to_table: :users }
    end
  end
end
