class AddNotNullConstraintsToBooleans < ActiveRecord::Migration[7.0]
    def change
      change_column_null :collections, :email_when_participants_changed, false, true
      change_column_null :collections, :email_depositors_status_changed, false, true
      change_column_null :collections, :review_enabled, false, true
  
      change_column_null :page_contents, :visible, false, true
      change_column_null :page_contents, :link_visible, false, true
    end
  end
