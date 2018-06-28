class AddSpammerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :spammer, :boolean
    add_index :users, :spammer
  end
end
