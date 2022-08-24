class WorkLockState < ActiveRecord::Migration[7.0]
  def change
    add_column :works, :locked, :boolean, default: false, null: false
  end
end
