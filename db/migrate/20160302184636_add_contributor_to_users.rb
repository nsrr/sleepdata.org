class AddContributorToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :contributor, :boolean, null: false, default: false
    add_index :users, :contributor
  end
end
