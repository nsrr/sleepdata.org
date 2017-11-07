class AddCommercialTypeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :commercial_type, :string, null: false, default: "noncommercial"
    add_index :users, :commercial_type
  end
end
