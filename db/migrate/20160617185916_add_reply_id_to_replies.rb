class AddReplyIdToReplies < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :reply_id, :integer
    add_index :replies, :reply_id
  end
end
