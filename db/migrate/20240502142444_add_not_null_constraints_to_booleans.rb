class AddNotNullConstraintsToBooleans < ActiveRecord::Migration[7.0]
    def change
      change_column_null :collections, :email_when_participants_changed, false
      change_column_null :collections, :email_depositors_status_changed, false
      change_column_null :collections, :review_enabled, false
  
      change_column_null :page_contents, :visible, false
      change_column_null :page_contents, :link_visible, false
  
    end
  end
  