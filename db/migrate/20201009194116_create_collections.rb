class CreateCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :contact_email, null: false
      t.string :release_option
      t.string :release_duration
      t.date :release_date
      t.string :visibility, null: false
      t.string :required_license
      t.string :default_license
      t.boolean :email_when_participants_changed, default: true, null: true
      t.string :managers, null: false
      t.string :depositors
      t.string :reviewers

      t.timestamps
    end
  end
end
