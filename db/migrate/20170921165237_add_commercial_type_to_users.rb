class AddCommercialTypeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :commercial_type, :string
    add_index :users, :commercial_type
  end
end
