class CreatePageContents < ActiveRecord::Migration[7.0]
  def change
    create_table :page_contents do |t|
      t.string :page, null: false
      t.text :value, default: ''
      t.boolean :visible, default: false
      t.boolean :link_visible, default: false
      t.string :link_text, default: ''
      t.string :link_url, default: ''
      t.string :user

      t.timestamps
    end

    PageContent.create(page: 'home')
  end
end
