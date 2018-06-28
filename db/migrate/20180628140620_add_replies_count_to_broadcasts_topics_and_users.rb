class AddRepliesCountToBroadcastsTopicsAndUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :replies_count, :integer, null: false, default: 0
    add_index :broadcasts, :replies_count
    add_column :topics, :replies_count, :integer, null: false, default: 0
    add_index :topics, :replies_count
    add_column :users, :replies_count, :integer, null: false, default: 0
    add_index :users, :replies_count
  end
end
