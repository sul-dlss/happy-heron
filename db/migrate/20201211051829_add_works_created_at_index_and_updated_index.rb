class AddWorksCreatedAtIndexAndUpdatedIndex < ActiveRecord::Migration[6.0]
  change_table :works do |t|
    t.index :created_at
    t.index :updated_at
  end
end
