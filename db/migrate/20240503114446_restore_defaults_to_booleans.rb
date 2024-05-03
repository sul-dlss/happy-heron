class RestoreDefaultsToBooleans < ActiveRecord::Migration[7.0]
  def change
    change_column_default :collections, :email_when_participants_changed, true
    change_column_default :collections, :email_depositors_status_changed, true
  end
end
