class RenameEventWorkIdToEventable < ActiveRecord::Migration[6.0]
  def change
    remove_column :events, :work_id
    add_reference :events, :eventable, polymorphic: true
  end
end
