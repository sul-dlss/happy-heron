class AddCollectionRefToWorks < ActiveRecord::Migration[6.0]
  def change
    add_reference :works, :collection, null: false, foreign_key: true
  end
end
