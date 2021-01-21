class CreateContactEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_emails do |t|
      t.string :email

      t.timestamps
      t.references :emailable, polymorphic: true
    end
    remove_column :collections, :contact_email
    remove_column :works, :contact_email
  end
end
