class DropNotifications < ActiveRecord::Migration[7.0]
  def change
    drop_table :notifications
  end
end
