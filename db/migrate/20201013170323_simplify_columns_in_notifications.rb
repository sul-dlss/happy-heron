class SimplifyColumnsInNotifications < ActiveRecord::Migration[6.0]
  def change
    remove_column :notifications, :recipient_id, :integer
    remove_column :notifications, :action, :text
    remove_column :notifications, :notifiable_type, :string
    remove_column :notifications, :notifiable_id, :integer

    add_column :notifications, :opened_at, :datetime
    add_column :notifications, :text, :string, null: false

    add_index :notifications, :opened_at
  end
end
