class CreateMailPreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_preferences do |t|
      t.boolean :wanted, null: false, default: true
      t.string :email, null: false
      t.references :user, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: true
      t.index [:user_id, :collection_id, :email], unique: true
      t.timestamps
    end
  end
end
