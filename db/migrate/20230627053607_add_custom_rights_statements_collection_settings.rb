class AddCustomRightsStatementsCollectionSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :collections, :allow_custom_rights_statement, :boolean, null: false, default: false
    add_column :collections, :provided_custom_rights_statement, :string
    add_column :collections, :custom_rights_statement_custom_instructions, :string
  end
end
