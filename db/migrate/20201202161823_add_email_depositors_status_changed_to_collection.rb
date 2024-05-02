class AddEmailDepositorsStatusChangedToCollection < ActiveRecord::Migration[6.0]
  def change
    add_column :collections, :email_depositors_status_changed, :boolean, default: true, null: true
  end
end
