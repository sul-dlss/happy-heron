class ChangeEventToAllowNilUser < ActiveRecord::Migration[6.1]
  def change
    change_column_null :events, :user_id, true
  end
end
