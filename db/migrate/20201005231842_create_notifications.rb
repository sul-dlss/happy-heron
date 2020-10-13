class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :recipient_id
      t.string :action
      t.string :notifiable_type
      t.integer :notifiable_id

      t.timestamps
    end
  end
end
