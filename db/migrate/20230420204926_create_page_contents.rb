class CreatePageContents < ActiveRecord::Migration[7.0]
  def change
    create_table :page_contents do |t|
      t.string :page, null: false, default: 'home'
      t.text :value, default: ''
      t.boolean :visible, default: false
      t.string :user

      t.timestamps
    end

    PageContent.create(page: 'home', visible: false)
  end
end
