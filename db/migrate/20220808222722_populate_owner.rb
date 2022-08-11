class PopulateOwner < ActiveRecord::Migration[7.0]
  def up
    Work.update_all("owner_id = depositor_id")
    change_column_null(:works, :owner_id, false)
  end
end
