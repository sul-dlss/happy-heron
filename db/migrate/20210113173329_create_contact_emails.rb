class CreateContactEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_emails do |t|
      t.string :email

      t.timestamps
    end
    add_reference :contact_emails, :emailable, polymorphic: true
    remove_column :collections, :contact_email
    remove_column :works, :contact_email
  end
end
