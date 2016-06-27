class AddBroadcastIdToReplies < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :broadcast_id, :integer
    add_index :replies, :broadcast_id
    add_index :replies, :topic_id
    add_index :replies, :user_id
    add_index :replies, :deleted
  end
end
