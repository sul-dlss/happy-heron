class AddCocinaTypeToKeywords < ActiveRecord::Migration[6.1]
  def change
    add_column :keywords, :cocina_type, :string
  end
end
