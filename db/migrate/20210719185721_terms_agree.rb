class TermsAgree < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_work_terms_agreement, :datetime, null: true
  end
end
